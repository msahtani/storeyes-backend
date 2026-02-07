package io.storeyes.storeyes_coffee.charges.controllers;

import io.storeyes.storeyes_coffee.charges.dto.*;
import io.storeyes.storeyes_coffee.charges.entities.ChargeCategory;
import io.storeyes.storeyes_coffee.charges.entities.ChargePeriod;
import io.storeyes.storeyes_coffee.charges.entities.EmployeeType;
import io.storeyes.storeyes_coffee.charges.services.ChargeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/charges")
@RequiredArgsConstructor
public class ChargeController {

    private final ChargeService chargeService;

    // ==================== Fixed Charges Endpoints ====================

    /**
     * Get all fixed charges
     * GET /api/charges/fixed
     */
    @GetMapping("/fixed")
    public ResponseEntity<Map<String, Object>> getAllFixedCharges(
            @RequestParam(required = false) String month,
            @RequestParam(required = false) ChargeCategory category,
            @RequestParam(required = false) ChargePeriod period) {
        
        List<FixedChargeResponse> charges = chargeService.getAllFixedCharges(month, category, period);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charges);
        response.put("message", "Fixed charges retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get fixed charge by ID
     * GET /api/charges/fixed/{id}
     */
    @GetMapping("/fixed/{id}")
    public ResponseEntity<Map<String, Object>> getFixedChargeById(
            @PathVariable Long id,
            @RequestParam(required = false) String month) {
        
        FixedChargeDetailResponse charge = chargeService.getFixedChargeById(id, month);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charge);
        response.put("message", "Fixed charge retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Create fixed charge
     * POST /api/charges/fixed
     */
    @PostMapping("/fixed")
    public ResponseEntity<Map<String, Object>> createFixedCharge(@Valid @RequestBody FixedChargeCreateRequest request) {
        try {
            FixedChargeResponse charge = chargeService.createFixedCharge(request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("data", charge);
            response.put("message", "Fixed charge created successfully");
            response.put("timestamp", java.time.OffsetDateTime.now());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to create charge");
            errorResponse.put("message", e.getMessage() != null ? e.getMessage() : "An error occurred while creating the charge");
            errorResponse.put("timestamp", java.time.OffsetDateTime.now());
            
            HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
            String message = e.getMessage();
            if (message != null) {
                String lowerMessage = message.toLowerCase();
                if (lowerMessage.contains("not found") || 
                    lowerMessage.contains("required") ||
                    lowerMessage.contains("invalid") ||
                    lowerMessage.contains("must be") ||
                    lowerMessage.contains("cannot be null") ||
                    lowerMessage.contains("format")) {
                    status = HttpStatus.BAD_REQUEST;
                }
            }
            
            return ResponseEntity.status(status).body(errorResponse);
        }
    }

    /**
     * Update fixed charge
     * PUT /api/charges/fixed/{id}
     */
    @PutMapping("/fixed/{id}")
    public ResponseEntity<Map<String, Object>> updateFixedCharge(
            @PathVariable Long id,
            @Valid @RequestBody FixedChargeUpdateRequest request) {
        
        FixedChargeResponse charge = chargeService.updateFixedCharge(id, request);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charge);
        response.put("message", "Fixed charge updated successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Delete fixed charge
     * DELETE /api/charges/fixed/{id}
     */
    @DeleteMapping("/fixed/{id}")
    public ResponseEntity<Void> deleteFixedCharge(@PathVariable Long id) {
        chargeService.deleteFixedCharge(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    /**
     * Get fixed charges by month
     * GET /api/charges/fixed/month/{monthKey}
     */
    @GetMapping("/fixed/month/{monthKey}")
    public ResponseEntity<Map<String, Object>> getFixedChargesByMonth(@PathVariable String monthKey) {
        List<FixedChargeResponse> charges = chargeService.getFixedChargesByMonth(monthKey);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charges);
        response.put("message", "Fixed charges retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get fixed charges by week for a specific month
     * GET /api/charges/fixed/month/{monthKey}/week/{weekKey}
     * Useful for displaying week-by-week breakdown of personnel charges
     */
    @GetMapping("/fixed/month/{monthKey}/week/{weekKey}")
    public ResponseEntity<Map<String, Object>> getFixedChargesByWeek(
            @PathVariable String monthKey,
            @PathVariable String weekKey,
            @RequestParam(required = false) ChargeCategory category) {
        
        List<FixedChargeResponse> charges = chargeService.getFixedChargesByWeek(monthKey, weekKey, category);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charges);
        response.put("message", "Fixed charges retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get available employees for reuse
     * GET /api/charges/fixed/personnel/employees
     */
    @GetMapping("/fixed/personnel/employees")
    public ResponseEntity<Map<String, Object>> getAvailableEmployees(@RequestParam(required = false) EmployeeType type) {
        List<PersonnelEmployeeResponse> employees = chargeService.getAvailableEmployees(type);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", employees);
        response.put("message", "Employees retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get authenticated user's last used period for personnel fixed charges (week or month).
     * GET /api/charges/fixed/personnel/last-period
     */
    @GetMapping("/fixed/personnel/last-period")
    public ResponseEntity<Map<String, Object>> getPersonnelChargeLastPeriod() {
        java.util.Optional<String> period = chargeService.getPersonnelChargeLastPeriod();
        Map<String, Object> data = new HashMap<>();
        data.put("period", period.orElse("month"));
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Last period retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Save authenticated user's last used period for personnel fixed charges.
     * PUT /api/charges/fixed/personnel/last-period
     */
    @PutMapping("/fixed/personnel/last-period")
    public ResponseEntity<Map<String, Object>> setPersonnelChargeLastPeriod(
            @Valid @RequestBody SetPersonnelLastPeriodRequest request) {
        chargeService.setPersonnelChargeLastPeriod(request.getPeriod());
        Map<String, Object> data = new HashMap<>();
        data.put("period", request.getPeriod());
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Last period saved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    // ==================== Variable Charges Endpoints ====================

    /**
     * Get all variable charges
     * GET /api/charges/variable
     */
    @GetMapping("/variable")
    public ResponseEntity<Map<String, Object>> getAllVariableCharges(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String category) {
        
        List<VariableChargeResponse> charges = chargeService.getAllVariableCharges(startDate, endDate, category);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charges);
        response.put("message", "Variable charges retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get variable charge by ID
     * GET /api/charges/variable/{id}
     */
    @GetMapping("/variable/{id}")
    public ResponseEntity<Map<String, Object>> getVariableChargeById(@PathVariable Long id) {
        VariableChargeResponse charge = chargeService.getVariableChargeById(id);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charge);
        response.put("message", "Variable charge retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Create variable charge
     * POST /api/charges/variable
     */
    @PostMapping("/variable")
    public ResponseEntity<Map<String, Object>> createVariableCharge(@Valid @RequestBody VariableChargeCreateRequest request) {
        VariableChargeResponse charge = chargeService.createVariableCharge(request);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charge);
        response.put("message", "Variable charge created successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Update variable charge
     * PUT /api/charges/variable/{id}
     */
    @PutMapping("/variable/{id}")
    public ResponseEntity<Map<String, Object>> updateVariableCharge(
            @PathVariable Long id,
            @Valid @RequestBody VariableChargeUpdateRequest request) {
        
        VariableChargeResponse charge = chargeService.updateVariableCharge(id, request);
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", charge);
        response.put("message", "Variable charge updated successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Delete variable charge
     * DELETE /api/charges/variable/{id}
     */
    @DeleteMapping("/variable/{id}")
    public ResponseEntity<Void> deleteVariableCharge(@PathVariable Long id) {
        chargeService.deleteVariableCharge(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
