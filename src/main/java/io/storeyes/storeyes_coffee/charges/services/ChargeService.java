package io.storeyes.storeyes_coffee.charges.services;

import io.storeyes.storeyes_coffee.charges.dto.*;
import io.storeyes.storeyes_coffee.charges.entities.*;
import io.storeyes.storeyes_coffee.charges.repositories.FixedChargeRepository;
import io.storeyes.storeyes_coffee.charges.repositories.PersonnelEmployeeRepository;
import io.storeyes.storeyes_coffee.charges.repositories.VariableChargeRepository;
import io.storeyes.storeyes_coffee.security.KeycloakTokenUtils;
import io.storeyes.storeyes_coffee.store.entities.Store;
import io.storeyes.storeyes_coffee.store.repositories.StoreRepository;
import io.storeyes.storeyes_coffee.store.services.StoreService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChargeService {

    private final FixedChargeRepository fixedChargeRepository;
    private final PersonnelEmployeeRepository personnelEmployeeRepository;
    private final VariableChargeRepository variableChargeRepository;
    private final StoreRepository storeRepository;
    private final StoreService storeService;

    private static final BigDecimal THRESHOLD_PERCENTAGE = BigDecimal.valueOf(20);
    private static final int SCALE = 2;
    private static final int PRECISION_SCALE = 4;

    // ==================== Fixed Charges ====================

    /**
     * Get store ID from authenticated user
     */
    private Long getStoreId() {
        String userId = KeycloakTokenUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User is not authenticated");
        }
        return storeService.getStoreByOwnerId(userId).getId();
    }

    /**
     * Get all fixed charges with optional filtering
     * Filters by authenticated user's store
     */
    public List<FixedChargeResponse> getAllFixedCharges(String month, ChargeCategory category, ChargePeriod period) {
        Long storeId = getStoreId();
        
        // Default to current month if not provided
        if (month == null || month.isEmpty()) {
            month = YearMonth.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }

        List<FixedCharge> charges;
        if (category != null && period != null) {
            charges = fixedChargeRepository.findByStoreIdAndCategoryAndMonthKeyAndPeriod(storeId, category, month, period);
        } else if (category != null) {
            charges = fixedChargeRepository.findByStoreIdAndCategoryAndMonthKey(storeId, category, month);
        } else if (period != null) {
            charges = fixedChargeRepository.findByStoreIdAndMonthKey(storeId, month).stream()
                    .filter(c -> c.getPeriod() == period)
                    .collect(Collectors.toList());
        } else {
            charges = fixedChargeRepository.findByStoreIdAndMonthKey(storeId, month);
        }

        return charges.stream()
                .map(this::toFixedChargeResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get fixed charge by ID with details
     * Verifies charge belongs to authenticated user's store
     */
    public FixedChargeDetailResponse getFixedChargeById(Long id, String month) {
        Long storeId = getStoreId();
        
        FixedCharge charge = fixedChargeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Fixed charge not found with id: " + id));

        // Verify charge belongs to user's store
        if (!charge.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Fixed charge not found with id: " + id);
        }

        return toFixedChargeDetailResponse(charge, month, storeId);
    }

    /**
     * Create a new fixed charge
     */
    @Transactional
    public FixedChargeResponse createFixedCharge(FixedChargeCreateRequest request) {
        // Validate request
        validateFixedChargeRequest(request);

        // Get store from authenticated user
        Long storeId = getStoreId();
        Store store = storeRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));

        // Build fixed charge
        FixedCharge charge = FixedCharge.builder()
                .store(store)
                .category(request.getCategory())
                .period(request.getPeriod())
                .monthKey(request.getMonthKey())
                .weekKey(request.getWeekKey())
                .notes(request.getNotes())
                .abnormalIncrease(false)
                .build();

        // Handle personnel charges with employees
        if (request.getCategory() == ChargeCategory.PERSONNEL) {
            if (request.getEmployees() == null || request.getEmployees().isEmpty()) {
                throw new RuntimeException("At least one employee is required for personnel charges");
            }

            // Process employees and calculate salaries
            List<PersonnelEmployee> employees = processEmployees(request.getEmployees(), charge, request.getPeriod(), request.getMonthKey(), request.getWeekKey());
            charge.setEmployees(employees);

            // Calculate total amount from employees if not provided
            if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) == 0) {
                BigDecimal totalAmount = calculateTotalAmountFromEmployees(employees, request.getPeriod(), request.getWeekKey());
                charge.setAmount(totalAmount);
            } else {
                charge.setAmount(request.getAmount());
            }
        } else {
            // For non-personnel charges, amount is required
            if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
                throw new RuntimeException("Amount is required for non-personnel charges");
            }
            charge.setAmount(request.getAmount());
        }

        // Calculate trend
        calculateAndSetTrend(charge, storeId);

        // Save charge (cascade will save employees)
        FixedCharge savedCharge = fixedChargeRepository.save(charge);

        return toFixedChargeResponse(savedCharge);
    }

    /**
     * Update fixed charge
     * Verifies charge belongs to authenticated user's store
     */
    @Transactional
    public FixedChargeResponse updateFixedCharge(Long id, FixedChargeUpdateRequest request) {
        Long storeId = getStoreId();
        
        FixedCharge charge = fixedChargeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Fixed charge not found with id: " + id));

        // Verify charge belongs to user's store
        if (!charge.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Fixed charge not found with id: " + id);
        }

        // Update fields if provided
        if (request.getAmount() != null) {
            charge.setAmount(request.getAmount());
        }
        if (request.getPeriod() != null) {
            charge.setPeriod(request.getPeriod());
        }
        if (request.getMonthKey() != null) {
            charge.setMonthKey(request.getMonthKey());
        }
        if (request.getWeekKey() != null) {
            charge.setWeekKey(request.getWeekKey());
        }
        if (request.getNotes() != null) {
            charge.setNotes(request.getNotes());
        }

        // Handle employee updates for personnel charges
        if (charge.getCategory() == ChargeCategory.PERSONNEL && request.getEmployees() != null) {
            // Remove existing employees
            charge.getEmployees().clear();

            // Process and add new employees
            List<PersonnelEmployee> employees = processEmployees(
                    request.getEmployees(),
                    charge,
                    request.getPeriod() != null ? request.getPeriod() : charge.getPeriod(),
                    request.getMonthKey() != null ? request.getMonthKey() : charge.getMonthKey(),
                    request.getWeekKey() != null ? request.getWeekKey() : charge.getWeekKey()
            );
            charge.setEmployees(employees);

            // Recalculate amount if not provided
            if (request.getAmount() == null) {
                BigDecimal totalAmount = calculateTotalAmountFromEmployees(
                        employees,
                        request.getPeriod() != null ? request.getPeriod() : charge.getPeriod(),
                        request.getWeekKey() != null ? request.getWeekKey() : charge.getWeekKey()
                );
                charge.setAmount(totalAmount);
            }
        }

        // Recalculate trend
        calculateAndSetTrend(charge, storeId);

        // Save updated charge
        FixedCharge updatedCharge = fixedChargeRepository.save(charge);

        return toFixedChargeResponse(updatedCharge);
    }

    /**
     * Delete fixed charge
     * Verifies charge belongs to authenticated user's store
     */
    @Transactional
    public void deleteFixedCharge(Long id) {
        Long storeId = getStoreId();
        
        FixedCharge charge = fixedChargeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Fixed charge not found with id: " + id));

        // Verify charge belongs to user's store
        if (!charge.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Fixed charge not found with id: " + id);
        }

        fixedChargeRepository.deleteById(id); // Cascade will delete employees
    }

    /**
     * Get fixed charges by month
     * Filters by authenticated user's store
     */
    public List<FixedChargeResponse> getFixedChargesByMonth(String monthKey) {
        Long storeId = getStoreId();
        List<FixedCharge> charges = fixedChargeRepository.findByStoreIdAndMonthKey(storeId, monthKey);
        return charges.stream()
                .map(this::toFixedChargeResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get available employees for reuse
     * Filters by authenticated user's store
     */
    public List<PersonnelEmployeeResponse> getAvailableEmployees(EmployeeType type) {
        Long storeId = getStoreId();
        List<PersonnelEmployee> employees = personnelEmployeeRepository.findDistinctEmployeesForReuse(storeId, type);
        
        // Group by name, type, position, and startDate to avoid duplicates
        Map<String, PersonnelEmployeeResponse> uniqueEmployees = new HashMap<>();
        for (PersonnelEmployee emp : employees) {
            String key = emp.getName() + "|" + 
                        (emp.getType() != null ? emp.getType().name() : "") + "|" +
                        (emp.getPosition() != null ? emp.getPosition() : "") + "|" +
                        (emp.getStartDate() != null ? emp.getStartDate().toString() : "");
            
            if (!uniqueEmployees.containsKey(key)) {
                uniqueEmployees.put(key, PersonnelEmployeeResponse.builder()
                        .id(emp.getId())
                        .name(emp.getName())
                        .type(emp.getType())
                        .position(emp.getPosition())
                        .startDate(emp.getStartDate())
                        .build());
            }
        }
        
        return new ArrayList<>(uniqueEmployees.values());
    }

    // ==================== Variable Charges ====================

    /**
     * Get all variable charges with optional filtering
     * Filters by authenticated user's store
     */
    public List<VariableChargeResponse> getAllVariableCharges(LocalDate startDate, LocalDate endDate, String category) {
        Long storeId = getStoreId();
        List<VariableCharge> charges = variableChargeRepository.findByStoreIdAndDateRangeAndCategory(storeId, startDate, endDate, category);
        return charges.stream()
                .map(this::toVariableChargeResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get variable charge by ID
     * Verifies charge belongs to authenticated user's store
     */
    public VariableChargeResponse getVariableChargeById(Long id) {
        Long storeId = getStoreId();
        
        VariableCharge charge = variableChargeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Variable charge not found with id: " + id));

        // Verify charge belongs to user's store
        if (!charge.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Variable charge not found with id: " + id);
        }

        return toVariableChargeResponse(charge);
    }

    /**
     * Create variable charge
     */
    @Transactional
    public VariableChargeResponse createVariableCharge(VariableChargeCreateRequest request) {
        // Get store from authenticated user
        Long storeId = getStoreId();
        Store store = storeRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));

        VariableCharge charge = VariableCharge.builder()
                .store(store)
                .name(request.getName())
                .amount(request.getAmount())
                .date(request.getDate())
                .category(request.getCategory())
                .supplier(request.getSupplier())
                .notes(request.getNotes())
                .purchaseOrderUrl(request.getPurchaseOrderUrl())
                .build();

        VariableCharge savedCharge = variableChargeRepository.save(charge);
        return toVariableChargeResponse(savedCharge);
    }

    /**
     * Update variable charge
     * Verifies charge belongs to authenticated user's store
     */
    @Transactional
    public VariableChargeResponse updateVariableCharge(Long id, VariableChargeUpdateRequest request) {
        Long storeId = getStoreId();
        
        VariableCharge charge = variableChargeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Variable charge not found with id: " + id));

        // Verify charge belongs to user's store
        if (!charge.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Variable charge not found with id: " + id);
        }

        if (request.getName() != null) {
            charge.setName(request.getName());
        }
        if (request.getAmount() != null) {
            charge.setAmount(request.getAmount());
        }
        if (request.getDate() != null) {
            charge.setDate(request.getDate());
        }
        if (request.getCategory() != null) {
            charge.setCategory(request.getCategory());
        }
        if (request.getSupplier() != null) {
            charge.setSupplier(request.getSupplier());
        }
        if (request.getNotes() != null) {
            charge.setNotes(request.getNotes());
        }
        if (request.getPurchaseOrderUrl() != null) {
            charge.setPurchaseOrderUrl(request.getPurchaseOrderUrl());
        }

        VariableCharge updatedCharge = variableChargeRepository.save(charge);
        return toVariableChargeResponse(updatedCharge);
    }

    /**
     * Delete variable charge
     * Verifies charge belongs to authenticated user's store
     */
    @Transactional
    public void deleteVariableCharge(Long id) {
        Long storeId = getStoreId();
        
        VariableCharge charge = variableChargeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Variable charge not found with id: " + id));

        // Verify charge belongs to user's store
        if (!charge.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Variable charge not found with id: " + id);
        }

        variableChargeRepository.deleteById(id);
    }

    // ==================== Salary Calculation Logic ====================

    /**
     * Process employees: create new or reuse existing, calculate salary distributions
     */
    private List<PersonnelEmployee> processEmployees(
            List<PersonnelEmployeeRequest> employeeRequests,
            FixedCharge charge,
            ChargePeriod period,
            String monthKey,
            String weekKey) {

        List<PersonnelEmployee> employees = new ArrayList<>();

        for (PersonnelEmployeeRequest empRequest : employeeRequests) {
            PersonnelEmployee employee;

            if (empRequest.getId() != null) {
                // Reuse existing employee - create new record but copy basic info
                PersonnelEmployee existing = personnelEmployeeRepository.findById(empRequest.getId())
                        .orElseThrow(() -> new RuntimeException("Employee not found with id: " + empRequest.getId()));
                
                employee = PersonnelEmployee.builder()
                        .fixedCharge(charge)
                        .name(existing.getName())
                        .type(existing.getType() != null ? existing.getType() : empRequest.getType())
                        .position(existing.getPosition() != null ? existing.getPosition() : empRequest.getPosition())
                        .startDate(existing.getStartDate() != null ? existing.getStartDate() : empRequest.getStartDate())
                        .hours(empRequest.getHours())
                        .build();
            } else {
                // Create new employee
                employee = PersonnelEmployee.builder()
                        .fixedCharge(charge)
                        .name(empRequest.getName())
                        .type(empRequest.getType())
                        .position(empRequest.getPosition())
                        .startDate(empRequest.getStartDate())
                        .hours(empRequest.getHours())
                        .build();
            }

            // Process salary if provided
            if (empRequest.getSalary() != null && empRequest.getSalary().compareTo(BigDecimal.ZERO) > 0) {
                if (period == ChargePeriod.MONTH) {
                    distributeMonthlySalary(employee, empRequest.getSalary(), monthKey);
                } else if (period == ChargePeriod.WEEK && weekKey != null) {
                    setWeeklySalary(employee, empRequest.getSalary(), weekKey, monthKey);
                }
            }

            employees.add(employee);
        }

        return employees;
    }

    /**
     * Distribute monthly salary across weeks and remaining days
     */
    private void distributeMonthlySalary(PersonnelEmployee employee, BigDecimal monthlySalary, String monthKey) {
        // Parse month key (YYYY-MM)
        YearMonth yearMonth = YearMonth.parse(monthKey);
        int daysInMonth = yearMonth.lengthOfMonth();

        // Calculate daily rate
        BigDecimal dailyRate = monthlySalary.divide(BigDecimal.valueOf(daysInMonth), PRECISION_SCALE, RoundingMode.HALF_UP);

        // Calculate full weeks and remaining days
        int fullWeeks = daysInMonth / 7;
        int remainingDays = daysInMonth % 7;

        // Calculate week salary (7 days)
        BigDecimal weekSalary = dailyRate.multiply(BigDecimal.valueOf(7)).setScale(SCALE, RoundingMode.HALF_UP);

        // Build week salaries map
        Map<String, BigDecimal> weekSalaries = new HashMap<>();
        for (int week = 1; week <= fullWeeks; week++) {
            String weekKey = monthKey + "-W" + week;
            weekSalaries.put(weekKey, weekSalary);
        }

        // Calculate remaining days salary
        BigDecimal daysLeftSalary = BigDecimal.ZERO;
        if (remainingDays > 0) {
            daysLeftSalary = dailyRate.multiply(BigDecimal.valueOf(remainingDays)).setScale(SCALE, RoundingMode.HALF_UP);
        }

        // Verify total matches monthly salary (adjust for rounding differences)
        BigDecimal calculatedTotal = weekSalary.multiply(BigDecimal.valueOf(fullWeeks))
                .add(daysLeftSalary);
        BigDecimal difference = monthlySalary.subtract(calculatedTotal);
        if (difference.abs().compareTo(BigDecimal.valueOf(0.01)) > 0) {
            // Adjust daysLeftSalary to match exactly
            daysLeftSalary = daysLeftSalary.add(difference);
        }

        // Set employee fields
        employee.setMonthSalary(monthlySalary);
        employee.setWeekSalary(weekSalary); // For backward compatibility
        employee.setWeekSalaries(weekSalaries);
        employee.setDaysLeftSalary(daysLeftSalary);
        employee.setSalary(monthlySalary);
        employee.setSalaryByPeriod(SalaryByPeriod.MONTH);
    }

    /**
     * Set weekly salary for a specific week
     */
    private void setWeeklySalary(PersonnelEmployee employee, BigDecimal weeklySalary, String weekKey, String monthKey) {
        // Get or initialize week salaries map
        Map<String, BigDecimal> weekSalaries = employee.getWeekSalaries();
        if (weekSalaries == null) {
            weekSalaries = new HashMap<>();
        }

        // Set salary for specific week
        weekSalaries.put(weekKey, weeklySalary);

        // Calculate month total from all week salaries
        BigDecimal totalWeekSalaries = weekSalaries.values().stream()
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Add days left salary if exists
        BigDecimal monthSalary = totalWeekSalaries;
        if (employee.getDaysLeftSalary() != null) {
            monthSalary = monthSalary.add(employee.getDaysLeftSalary());
        }

        // Set employee fields
        employee.setWeekSalaries(weekSalaries);
        employee.setWeekSalary(weeklySalary); // For display
        employee.setMonthSalary(monthSalary);
        employee.setSalary(weeklySalary); // For display
        employee.setSalaryByPeriod(SalaryByPeriod.WEEK);
    }

    /**
     * Calculate total amount from employees
     */
    private BigDecimal calculateTotalAmountFromEmployees(List<PersonnelEmployee> employees, ChargePeriod period, String weekKey) {
        BigDecimal total = BigDecimal.ZERO;

        for (PersonnelEmployee emp : employees) {
            BigDecimal empAmount = BigDecimal.ZERO;

            if (period == ChargePeriod.MONTH) {
                // Use monthSalary if exists, otherwise calculate from weekSalaries + daysLeftSalary
                if (emp.getMonthSalary() != null) {
                    empAmount = emp.getMonthSalary();
                } else if (emp.getWeekSalaries() != null && !emp.getWeekSalaries().isEmpty()) {
                    BigDecimal weekTotal = emp.getWeekSalaries().values().stream()
                            .reduce(BigDecimal.ZERO, BigDecimal::add);
                    if (emp.getDaysLeftSalary() != null) {
                        empAmount = weekTotal.add(emp.getDaysLeftSalary());
                    } else {
                        empAmount = weekTotal;
                    }
                } else if (emp.getSalary() != null) {
                    empAmount = emp.getSalary();
                }
            } else if (period == ChargePeriod.WEEK && weekKey != null) {
                // Use weekSalaries[weekKey] if exists, otherwise use weekSalary or salary
                if (emp.getWeekSalaries() != null && emp.getWeekSalaries().containsKey(weekKey)) {
                    empAmount = emp.getWeekSalaries().get(weekKey);
                } else if (emp.getWeekSalary() != null) {
                    empAmount = emp.getWeekSalary();
                } else if (emp.getSalary() != null) {
                    empAmount = emp.getSalary();
                }
            }

            total = total.add(empAmount);
        }

        return total.setScale(SCALE, RoundingMode.HALF_UP);
    }

    // ==================== Trend Calculation ====================

    /**
     * Calculate and set trend for a fixed charge
     */
    private void calculateAndSetTrend(FixedCharge charge, Long storeId) {
        List<FixedCharge> previousCharges = fixedChargeRepository.findPreviousCharges(
                storeId,
                charge.getCategory(),
                charge.getPeriod(),
                charge.getMonthKey(),
                charge.getWeekKey() != null ? charge.getWeekKey() : ""
        );

        if (!previousCharges.isEmpty()) {
            FixedCharge previousCharge = previousCharges.get(0);
            BigDecimal previousAmount = previousCharge.getAmount();
            BigDecimal currentAmount = charge.getAmount();

            // Calculate difference
            BigDecimal difference = currentAmount.subtract(previousAmount);

            // Calculate percentage
            BigDecimal percentage = BigDecimal.ZERO;
            if (previousAmount.compareTo(BigDecimal.ZERO) > 0) {
                percentage = difference.divide(previousAmount, PRECISION_SCALE, RoundingMode.HALF_UP)
                        .multiply(BigDecimal.valueOf(100))
                        .setScale(SCALE, RoundingMode.HALF_UP);
            }

            // Determine trend direction
            TrendDirection trend;
            if (difference.compareTo(BigDecimal.ZERO) > 0) {
                trend = TrendDirection.UP;
            } else if (difference.compareTo(BigDecimal.ZERO) < 0) {
                trend = TrendDirection.DOWN;
            } else {
                trend = TrendDirection.STABLE;
            }

            // Check for abnormal increase
            boolean abnormalIncrease = percentage.compareTo(THRESHOLD_PERCENTAGE) > 0;

            // Set fields
            charge.setTrend(trend);
            charge.setTrendPercentage(percentage);
            charge.setPreviousAmount(previousAmount);
            charge.setAbnormalIncrease(abnormalIncrease);
        } else {
            // No previous charge found
            charge.setTrend(null);
            charge.setTrendPercentage(null);
            charge.setPreviousAmount(null);
            charge.setAbnormalIncrease(false);
        }
    }

    // ==================== DTO Mapping ====================

    private FixedChargeResponse toFixedChargeResponse(FixedCharge charge) {
        return FixedChargeResponse.builder()
                .id(charge.getId())
                .category(charge.getCategory())
                .amount(charge.getAmount())
                .period(charge.getPeriod())
                .monthKey(charge.getMonthKey())
                .weekKey(charge.getWeekKey())
                .trend(charge.getTrend())
                .trendPercentage(charge.getTrendPercentage())
                .abnormalIncrease(charge.getAbnormalIncrease())
                .createdAt(charge.getCreatedAt())
                .updatedAt(charge.getUpdatedAt())
                .build();
    }

    private FixedChargeDetailResponse toFixedChargeDetailResponse(FixedCharge charge, String month, Long storeId) {
        FixedChargeDetailResponse response = FixedChargeDetailResponse.builder()
                .id(charge.getId())
                .category(charge.getCategory())
                .amount(charge.getAmount())
                .period(charge.getPeriod())
                .monthKey(charge.getMonthKey())
                .weekKey(charge.getWeekKey())
                .trend(charge.getTrend())
                .trendPercentage(charge.getTrendPercentage())
                .abnormalIncrease(charge.getAbnormalIncrease())
                .previousAmount(charge.getPreviousAmount())
                .notes(charge.getNotes())
                .createdAt(charge.getCreatedAt())
                .updatedAt(charge.getUpdatedAt())
                .build();

        // Build personnel data if category is PERSONNEL
        if (charge.getCategory() == ChargeCategory.PERSONNEL && charge.getEmployees() != null) {
            Map<EmployeeType, List<PersonnelEmployeeDTO>> groupedByType = charge.getEmployees().stream()
                    .map(this::toPersonnelEmployeeDTO)
                    .collect(Collectors.groupingBy(emp -> emp.getType() != null ? emp.getType() : EmployeeType.SERVER));

            List<PersonnelDataDTO> personnelData = new ArrayList<>();
            for (Map.Entry<EmployeeType, List<PersonnelEmployeeDTO>> entry : groupedByType.entrySet()) {
                BigDecimal totalAmount = entry.getValue().stream()
                        .map(emp -> emp.getSalary() != null ? emp.getSalary() : BigDecimal.ZERO)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

                personnelData.add(PersonnelDataDTO.builder()
                        .type(entry.getKey())
                        .totalAmount(totalAmount)
                        .employees(entry.getValue())
                        .build());
            }
            response.setPersonnelData(personnelData);
        }

        // Build chart data (historical charges)
        List<FixedCharge> historicalCharges = fixedChargeRepository.findHistoricalCharges(
                storeId,
                charge.getCategory(),
                charge.getPeriod(),
                month != null ? month : charge.getMonthKey()
        );
        List<ChartDataDTO> chartData = historicalCharges.stream()
                .map(hc -> ChartDataDTO.builder()
                        .period(formatMonthKey(hc.getMonthKey()))
                        .amount(hc.getAmount())
                        .build())
                .collect(Collectors.toList());
        response.setChartData(chartData);

        return response;
    }

    private PersonnelEmployeeDTO toPersonnelEmployeeDTO(PersonnelEmployee emp) {
        return PersonnelEmployeeDTO.builder()
                .id(emp.getId())
                .name(emp.getName())
                .type(emp.getType())
                .position(emp.getPosition())
                .startDate(emp.getStartDate())
                .salary(emp.getSalary())
                .hours(emp.getHours())
                .salaryByPeriod(emp.getSalaryByPeriod())
                .monthSalary(emp.getMonthSalary())
                .weekSalary(emp.getWeekSalary())
                .weekSalaries(emp.getWeekSalaries())
                .daysLeftSalary(emp.getDaysLeftSalary())
                .build();
    }

    private VariableChargeResponse toVariableChargeResponse(VariableCharge charge) {
        return VariableChargeResponse.builder()
                .id(charge.getId())
                .name(charge.getName())
                .amount(charge.getAmount())
                .date(charge.getDate())
                .category(charge.getCategory())
                .supplier(charge.getSupplier())
                .notes(charge.getNotes())
                .purchaseOrderUrl(charge.getPurchaseOrderUrl())
                .createdAt(charge.getCreatedAt())
                .updatedAt(charge.getUpdatedAt())
                .build();
    }

    // ==================== Helper Methods ====================

    private void validateFixedChargeRequest(FixedChargeCreateRequest request) {
        if (request.getPeriod() == ChargePeriod.WEEK && (request.getWeekKey() == null || request.getWeekKey().isEmpty())) {
            throw new RuntimeException("Week key is required when period is WEEK");
        }

        if (request.getCategory() != ChargeCategory.PERSONNEL && 
            (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0)) {
            throw new RuntimeException("Amount is required for non-personnel charges");
        }

        // Validate utilities must be MONTH period
        if (request.getCategory() != ChargeCategory.PERSONNEL && request.getPeriod() != ChargePeriod.MONTH) {
            throw new RuntimeException("Utilities (water, electricity, wifi) must use MONTH period");
        }
    }

    private String formatMonthKey(String monthKey) {
        // Format "YYYY-MM" to "MMM YYYY" (e.g., "2024-03" -> "Mar 2024")
        if (monthKey == null || monthKey.length() != 7) {
            return monthKey;
        }
        try {
            YearMonth yearMonth = YearMonth.parse(monthKey);
            return yearMonth.format(DateTimeFormatter.ofPattern("MMM yyyy"));
        } catch (Exception e) {
            return monthKey;
        }
    }
}
