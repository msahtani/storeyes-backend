package io.storeyes.storeyes_coffee.notification.controllers;

import io.storeyes.storeyes_coffee.clientgw.config.ClientGwProperties;
import io.storeyes.storeyes_coffee.notification.dto.DailyAlertsNotificationRequest;
import io.storeyes.storeyes_coffee.notification.dto.DailyKpiNotificationRequest;
import io.storeyes.storeyes_coffee.notification.dto.SendNotificationRequest;
import io.storeyes.storeyes_coffee.notification.services.NotificationService;
import io.storeyes.storeyes_coffee.store.entities.Store;
import io.storeyes.storeyes_coffee.store.repositories.StoreRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private static final String STORE_CODE_HEADER = "X-STORE-CODE";
    private static final String API_KEY_HEADER = "X-API-KEY";
    private static final List<String> OWNER_ROLES = List.of("OWNER");

    private final StoreRepository storeRepository;
    private final NotificationService notificationService;
    private final ClientGwProperties clientGwProperties;

    /**
     * Open endpoint: notify all users attached to a store about its daily KPI (RAZ).
     * POST /api/notifications/daily-kpi
     *
     * Headers:
     * - X-STORE-CODE: store code (required)
     *
     * Body:
     * { "raz": 1234.56 }
     *
     * Sends a push to every active device of users mapped to the store with a message like
     * "{store name} received {raz} DH today".
     *
     * Returns: { "storeId": ..., "store": "...", "notified": <count sent successfully> }
     */
    @PostMapping("/daily-kpi")
    public ResponseEntity<Map<String, Object>> notifyDailyKpi(
            @RequestHeader(STORE_CODE_HEADER) String storeCode,
            @Valid @RequestBody DailyKpiNotificationRequest request) {

        Store store = storeRepository.findByCode(storeCode)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Store not found with code: " + storeCode));

        String body = store.getName() + " received " + formatRaz(request.getRaz()) + " DH today";

        SendNotificationRequest notification = new SendNotificationRequest();
        notification.setStoreId(store.getId());
        notification.setTitle("Daily KPI");
        notification.setBody(body);

        int notified = notificationService.send(notification);
        log.debug("Daily KPI notification for store '{}' (id={}) sent to {} device(s): {}",
                store.getName(), store.getId(), notified, body);

        return ResponseEntity.ok(Map.of(
                "storeId", store.getId(),
                "store", store.getName(),
                "notified", notified
        ));
    }

    /**
     * Secured endpoint: notify a store's OWNER(s) that a day's alerts were just published.
     * POST /api/notifications/daily-alerts
     *
     * Headers:
     * - X-STORE-CODE: store code (required)
     * - X-API-KEY: shared client-gw key (required — unlike {@link #notifyDailyKpi}, this
     *   endpoint is admin-panel-triggered only, so it's locked down)
     *
     * Body:
     * { "date": "2026-07-03", "count": 3 }
     *
     * Sends "you have {count} alert(s) on {date}" (e.g. "you have 3 alert(s) on July 3rd") to
     * every active device of users holding the OWNER role at the store.
     *
     * Returns: { "storeId": ..., "store": "...", "notified": <count sent successfully> }
     */
    @PostMapping("/daily-alerts")
    public ResponseEntity<Map<String, Object>> notifyDailyAlerts(
            @RequestHeader(STORE_CODE_HEADER) String storeCode,
            @RequestHeader(API_KEY_HEADER) String apiKey,
            @Valid @RequestBody DailyAlertsNotificationRequest request) {

        if (apiKey == null || apiKey.isBlank() || !apiKey.equals(clientGwProperties.getApiKey())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid API key");
        }

        Store store = storeRepository.findByCode(storeCode)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Store not found with code: " + storeCode));

        String body = "you have " + request.getCount() + " alert(s) on " + formatWithOrdinal(request.getDate());

        SendNotificationRequest notification = new SendNotificationRequest();
        notification.setStoreId(store.getId());
        notification.setRoles(OWNER_ROLES);
        notification.setTitle("New Alerts");
        notification.setBody(body);

        int notified = notificationService.send(notification);
        log.debug("Daily alerts notification for store '{}' (id={}) sent to {} device(s): {}",
                store.getName(), store.getId(), notified, body);

        return ResponseEntity.ok(Map.of(
                "storeId", store.getId(),
                "store", store.getName(),
                "notified", notified
        ));
    }

    /** Formats a date like "July 3rd". */
    private String formatWithOrdinal(LocalDate date) {
        int day = date.getDayOfMonth();
        String month = date.format(DateTimeFormatter.ofPattern("MMMM"));
        return month + " " + day + ordinalSuffix(day);
    }

    private String ordinalSuffix(int day) {
        if (day >= 11 && day <= 13) {
            return "th";
        }
        return switch (day % 10) {
            case 1 -> "st";
            case 2 -> "nd";
            case 3 -> "rd";
            default -> "th";
        };
    }

    /** Trims a trailing ".0" so whole amounts read "1200" instead of "1200.0". */
    private String formatRaz(Double raz) {
        if (raz == raz.longValue()) {
            return String.valueOf(raz.longValue());
        }
        return String.valueOf(raz);
    }
}
