package io.storeyes.storeyes_coffee.alerts.services;

import io.storeyes.storeyes_coffee.alerts.dto.AlertDTO;
import io.storeyes.storeyes_coffee.alerts.dto.AlertDetailsDTO;
import io.storeyes.storeyes_coffee.alerts.dto.AlertSettingsDTO;
import io.storeyes.storeyes_coffee.alerts.entities.Alert;
import io.storeyes.storeyes_coffee.alerts.entities.HumanJudgement;
import io.storeyes.storeyes_coffee.alerts.mappers.AlertMapper;
import io.storeyes.storeyes_coffee.alerts.repositories.AlertRepository;
import io.storeyes.storeyes_coffee.clientgw.dto.CgAlertClassDTO;
import io.storeyes.storeyes_coffee.clientgw.services.ClientGwLookupService;
import io.storeyes.storeyes_coffee.dailyalert.entities.DailyAlert;
import io.storeyes.storeyes_coffee.dailyalert.repositories.DailyAlertRepository;
import io.storeyes.storeyes_coffee.sales.dto.SalesDTO;
import io.storeyes.storeyes_coffee.sales.entities.CoffeeSalesHourly;
import io.storeyes.storeyes_coffee.sales.repositories.CoffeeSalesHourlyRepository;
import io.storeyes.storeyes_coffee.security.CurrentStoreContext;
import io.storeyes.storeyes_coffee.store.entities.Store;
import io.storeyes.storeyes_coffee.store.repositories.StoreRepository;
import io.storeyes.storeyes_coffee.store.services.DemoStoreDataSourceResolver;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AlertService {

    private final AlertRepository alertRepository;
    private final AlertMapper alertMapper;
    private final StoreRepository storeRepository;
    private final DemoStoreDataSourceResolver demoStoreDataSourceResolver;
    private final ClientGwLookupService clientGwLookupService;
    private final DailyAlertRepository dailyAlertRepository;
    private final CoffeeSalesHourlyRepository coffeeSalesHourlyRepository;

    /** How many recent orders to attach to an alert's detail view. */
    private static final int ALERT_DETAIL_RECENT_ORDERS = 5;
    
    /**
     * Get alerts by date and processed status (supports both exact date and date range).
     * Store is resolved from CurrentStoreContext (set by StoreContextInterceptor).
     * By default returns processed alerts, unless unprocessed=true.
     * If date is not provided, defaults to today's date.
     * If returnType=true, returns only alerts with alertType=RETURN.
     * If alertType is provided (NOT_TAPPED or RETURN), returns only alerts of that type (takes precedence over returnType).
     *
     * <p><b>Demo-store date substitution:</b> when the demo store mapping carries a non-null
     * {@code alertDate}, the DB query targets that fixed date instead of the caller-supplied
     * {@code date}. After fetching, each returned alert's {@code alertDate} is rewritten so
     * that its <em>date</em> portion matches the original caller-supplied {@code ?date=} value
     * while preserving the original time-of-day component.</p>
     */
    public List<Alert> getAlertsByDate(LocalDateTime date, LocalDateTime endDate, Boolean unprocessed, Boolean returnType, io.storeyes.storeyes_coffee.alerts.entities.AlertType alertType) {
        Long storeId = CurrentStoreContext.getCurrentStoreId();
        if (storeId == null) {
            throw new RuntimeException("Store context not found for current user");
        }

        // Per-store alert-type visibility. Read from the selected store (not the demo
        // data store): the demo mapping only redirects where alert data comes from,
        // while the visibility configuration belongs to the real store.
        boolean notTappedEnabled = true;
        boolean returnEnabled = true;
        var currentStore = storeRepository.findById(storeId).orElse(null);
        if (currentStore != null) {
            notTappedEnabled = currentStore.isNotTappedAlertsEnabled();
            returnEnabled = currentStore.isReturnAlertsEnabled();
            // Alerts locked until the activation date (default creation + 3 weeks);
            // null activation date (legacy stores) counts as active.
            if (!isAlertsActive(currentStore)) {
                return List.of();
            }
        }

        // Resolve demo-store context (data store + optional fixed alert date).
        DemoStoreDataSourceResolver.AlertsDataContext alertsCtx =
                demoStoreDataSourceResolver.resolveAlertsDataContext(storeId);
        Long dataStoreId = alertsCtx.dataStoreId();
        LocalDate demoAlertDate = alertsCtx.alertDate(); // null for non-demo stores

        boolean filterUnprocessed = Boolean.TRUE.equals(unprocessed);
        boolean filterReturnType = Boolean.TRUE.equals(returnType);
        // alertType param takes precedence; if not set, fall back to returnType for backward compat
        io.storeyes.storeyes_coffee.alerts.entities.AlertType filterAlertType = alertType != null
                ? alertType
                : (filterReturnType ? io.storeyes.storeyes_coffee.alerts.entities.AlertType.RETURN : null);

        // Default to today's date if not provided; keep a reference to rewrite results later.
        final LocalDateTime requestedDate = (date != null) ? date : LocalDate.now().atStartOfDay();

        // When the demo mapping carries a fixed alertDate, substitute the date portion of the
        // query parameters so we hit the actual rows in the source store.
        LocalDateTime queryDate;
        LocalDateTime queryEndDate;
        if (demoAlertDate != null) {
            queryDate    = demoAlertDate.atTime(requestedDate.toLocalTime());
            queryEndDate = (endDate != null) ? demoAlertDate.atTime(endDate.toLocalTime()) : null;
        } else {
            queryDate    = requestedDate;
            queryEndDate = endDate;
        }

        // Daily visibility gate (toggled by admin staff in st-admin-back): a missing row counts
        // as visible (fail-open) — only an explicit is_visible = false row hides that day's
        // alerts. Applied whenever the query resolves to a single calendar day — either no
        // endDate was given, or endDate falls on the same day as the start (a same-day range,
        // e.g. startDate=endDate=2026-08-02). True multi-day ranges are intentionally left
        // ungated; the gate is per-day and a per-row check across a range isn't worth the
        // complexity here.
        boolean singleDayQuery = queryEndDate == null
                || queryEndDate.toLocalDate().equals(queryDate.toLocalDate());
        if (singleDayQuery) {
            boolean dailyAlertsVisible = dailyAlertRepository
                    .findByStoreIdAndDate(dataStoreId, queryDate.toLocalDate())
                    .map(DailyAlert::isVisible)
                    .orElse(true);
            if (!dailyAlertsVisible) {
                return List.of();
            }
        }

        List<Alert> alerts;
        if (queryEndDate != null) {
            // Date range
            if (filterUnprocessed) {
                alerts = alertRepository.findUnprocessedByAlertDateBetweenAndStoreId(queryDate, queryEndDate, dataStoreId);
            } else {
                // Default list: processed alerts + unprocessed alerts judged TRUE_POSITIVE
                alerts = alertRepository.findDefaultListByAlertDateBetweenAndStoreId(queryDate, queryEndDate, dataStoreId);
            }
        } else {
            // Exact date (or defaulted to today)
            if (filterUnprocessed) {
                alerts = alertRepository.findUnprocessedByAlertDateAndStoreId(queryDate, dataStoreId);
            } else {
                // Default list: processed alerts + unprocessed alerts judged TRUE_POSITIVE
                alerts = alertRepository.findDefaultListByAlertDateAndStoreId(queryDate, dataStoreId);
            }
        }

        // When a fixed demo alertDate was used, rewrite each alert's date portion back to the
        // caller-supplied date so the response appears to belong to the requested date.
        if (demoAlertDate != null) {
            LocalDate targetDate = requestedDate.toLocalDate();
            List<Alert> rewritten = new ArrayList<>(alerts.size());
            for (Alert a : alerts) {
                if (a.getAlertDate() != null) {
                    a.setAlertDate(a.getAlertDate().toLocalTime().atDate(targetDate));
                }
                rewritten.add(a);
            }
            alerts = rewritten;
        }

        // Apply type / judgement filters
        final boolean allowNotTapped = notTappedEnabled;
        final boolean allowReturn = returnEnabled;
        return alerts.stream()
                .filter(a -> {
                    // The store-facing app only ever displays NOT_TAPPED / RETURN; other types
                    // (e.g. UNKNOWN, TAPPED_LATER — admin-panel/device-gateway concepts) are
                    // never surfaced here, regardless of store settings or the alertType filter.
                    io.storeyes.storeyes_coffee.alerts.entities.AlertType type = a.getAlertType();
                    if (type != null
                            && type != io.storeyes.storeyes_coffee.alerts.entities.AlertType.NOT_TAPPED
                            && type != io.storeyes.storeyes_coffee.alerts.entities.AlertType.RETURN) {
                        return false;
                    }
                    // Drop alert types disabled for this store (null type counts as NOT_TAPPED)
                    boolean isReturn = type == io.storeyes.storeyes_coffee.alerts.entities.AlertType.RETURN;
                    if (isReturn ? !allowReturn : !allowNotTapped) return false;
                    // If alertType filter is set, only return matching alerts
                    if (filterAlertType != null) {
                        if (a.getAlertType() != filterAlertType) return false;
                    }
                    HumanJudgement h = a.getHumanJudgement();
                    // For unprocessed alerts, return only TRUE_POSITIVE alerts.
                    if (filterUnprocessed) {
                        return h == HumanJudgement.TRUE_POSITIVE;
                    }
                    // Otherwise, return alerts with humanJudgement NEW or TRUE_POSITIVE
                    return h == null || h == HumanJudgement.NEW || h == HumanJudgement.TRUE_POSITIVE;
                })
                .collect(Collectors.toList());
    }
    
    /**
     * Per-store alert-type visibility for the current user's selected store.
     * Reads the selected store directly (not the demo data store), since the
     * visibility configuration belongs to the real store.
     */
    public AlertSettingsDTO getAlertSettings() {
        long storeId = CurrentStoreContext.requireCurrentStoreId();
        var store = storeRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));
        return AlertSettingsDTO.builder()
                .notTappedEnabled(store.isNotTappedAlertsEnabled())
                .returnEnabled(store.isReturnAlertsEnabled())
                .alertsActive(isAlertsActive(store))
                .build();
    }

    /**
     * Alerts are locked until the store's activation date (default creation + 3 weeks);
     * a null activation date (legacy stores) counts as active.
     */
    private static boolean isAlertsActive(Store store) {
        LocalDateTime activation = store.getAlertsActivationDate();
        return activation == null || !LocalDateTime.now().isBefore(activation);
    }

    /**
     * Update human judgement directly via query
     */
    @Transactional
    public boolean updateHumanJudgement(Long alertId, HumanJudgement judgement) {
        LocalDateTime now = LocalDateTime.now();
        int updated = alertRepository.updateHumanJudgement(alertId, judgement, now);
        return updated > 0;
    }

    /**
     * Assigns (or clears, when {@code alertClassId} is null) an alert's classification tag.
     * Validates that the class is actually visible to the current store (global or that store's
     * own) before assigning it, so a store can't tag its alerts with another store's class by
     * guessing IDs.
     */
    @Transactional
    public boolean updateAlertClass(Long alertId, Long alertClassId) {
        if (alertClassId != null) {
            Long storeId = CurrentStoreContext.requireCurrentStoreId();
            boolean visible = clientGwLookupService.fetchAlertClasses(storeId).stream()
                    .anyMatch(c -> alertClassId.equals(c.getId()));
            if (!visible) {
                throw new IllegalArgumentException("Alert class not found: " + alertClassId);
            }
        }
        LocalDateTime now = LocalDateTime.now();
        int updated = alertRepository.updateAlertClassId(alertId, alertClassId, now);
        return updated > 0;
    }


    /**
     * Get alert details by alert ID.
     * <p>The {@code sales} list is the last {@value #ALERT_DETAIL_RECENT_ORDERS} orders at or before
     * the alert's hour, read straight from {@code coffee_sales_hourly} (matched on
     * {@code coffee_shop_name} = store code, resolved through the demo KPI source for demo stores)
     * — the {@code sales} entity table is not consulted.</p>
     * <p>If the current store is a demo store and {@code requestedDate} is provided (or defaults
     * to today), the returned DTO's {@code alertDate} is rewritten so its <em>date</em> portion
     * matches {@code requestedDate} while preserving the original time-of-day component.</p>
     *
     * @param id            alert primary key
     * @param requestedDate caller-supplied {@code ?date=} value; may be {@code null} (today used)
     * @return AlertDetailsDTO with recent orders
     */
    public AlertDetailsDTO getAlertDetailsWithSales(Long id, LocalDate requestedDate) {
        Alert alert = alertRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Alert not found with id: " + id));

        // Use mapper to convert Alert to AlertDetailsDTO
        AlertDetailsDTO dto = alertMapper.toDetailsDTO(alert);
        dto.setSales(fetchRecentOrders(alert));
        if (alert.getAlertClassId() != null) {
            Long storeId = CurrentStoreContext.getCurrentStoreId();
            if (storeId != null) {
                dto.setAlertClassName(fetchAlertClassNamesById(storeId).get(alert.getAlertClassId()));
            }
        }
        return dto;
    }

    /**
     * Resolves each alert's classification tag name (if any) and sets it on the matching DTO.
     * {@code alerts} and {@code dtos} must be the same size and in the same order (as produced by
     * {@link AlertMapper#toDTOList}). No-op if none of the alerts carry a class, or the current
     * store can't be resolved.
     */
    public void enrichAlertClassNames(List<Alert> alerts, List<AlertDTO> dtos) {
        boolean anyClassified = alerts.stream().anyMatch(a -> a.getAlertClassId() != null);
        if (!anyClassified) return;
        Long storeId = CurrentStoreContext.getCurrentStoreId();
        if (storeId == null) return;

        Map<Long, String> namesById = fetchAlertClassNamesById(storeId);
        if (namesById.isEmpty()) return;

        for (int i = 0; i < alerts.size() && i < dtos.size(); i++) {
            Long classId = alerts.get(i).getAlertClassId();
            if (classId != null) {
                dtos.get(i).setAlertClassName(namesById.get(classId));
            }
        }
    }

    private Map<Long, String> fetchAlertClassNamesById(Long storeId) {
        return clientGwLookupService.fetchAlertClasses(storeId).stream()
                .collect(Collectors.toMap(CgAlertClassDTO::getId, CgAlertClassDTO::getName, (a, b) -> a));
    }

    /**
     * Last {@value #ALERT_DETAIL_RECENT_ORDERS} orders at or before the alert's hour, read from
     * {@code coffee_sales_hourly} (matched on {@code coffee_shop_name} = store code) and mapped to
     * {@link SalesDTO}. Returns an empty list when the store code or the alert date can't be resolved.
     */
    private List<SalesDTO> fetchRecentOrders(Alert alert) {
        LocalDateTime alertDate = alert.getAlertDate();
        if (alertDate == null) {
            return List.of();
        }
        String storeCode = resolveSalesStoreCode(alert);
        if (storeCode == null || storeCode.isBlank()) {
            return List.of();
        }
        return coffeeSalesHourlyRepository
                .findRecentOrdersForStore(storeCode, alertDate.toLocalDate(),
                        alertDate.getHour(), ALERT_DETAIL_RECENT_ORDERS)
                .stream()
                .map(AlertService::toSalesDTO)
                .collect(Collectors.toList());
    }

    /**
     * Store code to match against {@code coffee_sales_hourly.coffee_shop_name} for this alert's
     * recent-orders list. When the current context store is a demo, the sales rows live under the
     * KPI/sales source store (the same store the rest of the app reads {@code coffee_sales_hourly}
     * from), so resolve that store's code; otherwise fall back to the alert's own store code.
     */
    private String resolveSalesStoreCode(Alert alert) {
        Long contextStoreId = CurrentStoreContext.getCurrentStoreId();
        if (contextStoreId != null) {
            Long dataStoreId = demoStoreDataSourceResolver.resolveKpiContext(contextStoreId).dataStoreId();
            String code = storeRepository.findById(dataStoreId).map(Store::getCode).orElse(null);
            if (code != null && !code.isBlank()) {
                return code;
            }
        }
        Store store = alert.getStore();
        return store != null ? store.getCode() : null;
    }

    private static SalesDTO toSalesDTO(CoffeeSalesHourly row) {
        return SalesDTO.builder()
                .id(row.getId())
                .soldAt(resolveSoldAt(row))
                .productName(row.getCoffeeName())
                .quantity(row.getQuantity() != null ? row.getQuantity().doubleValue() : null)
                .price(row.getPrice() != null ? row.getPrice().doubleValue() : null)
                .totalPrice(row.getTotalPrice() != null ? row.getTotalPrice().doubleValue() : null)
                .category(row.getCategory())
                .createdAt(row.getCreatedAt())
                .build();
    }

    /**
     * Best-effort order timestamp: {@code sale_date} + parsed {@code sale_time}, falling back to
     * the top of {@code hour} when {@code sale_time} is missing or unparseable, and to the start
     * of the day when there is no hour either.
     */
    private static LocalDateTime resolveSoldAt(CoffeeSalesHourly row) {
        if (row.getSaleDate() == null) {
            return null;
        }
        LocalTime time = null;
        String raw = row.getSaleTime();
        if (raw != null && !raw.isBlank()) {
            try {
                time = LocalTime.parse(raw.trim());
            } catch (DateTimeParseException ignored) {
                // fall through to the hour-based fallback
            }
        }
        if (time == null && row.getHour() != null && row.getHour() >= 0 && row.getHour() <= 23) {
            time = LocalTime.of(row.getHour(), 0);
        }
        return time != null ? LocalDateTime.of(row.getSaleDate(), time) : row.getSaleDate().atStartOfDay();
    }
}

