package io.storeyes.storeyes_coffee.alerts.controllers;

import io.storeyes.storeyes_coffee.alerts.dto.AlertSummaryDTO;
import io.storeyes.storeyes_coffee.alerts.services.AlertService;
import io.storeyes.storeyes_coffee.device.repositories.DeviceRepository;
import io.storeyes.storeyes_coffee.security.KeycloakTokenUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v2/alerts")
@RequiredArgsConstructor
public class AlertControllerV2 {
    
    private final AlertService alertService;
    private final DeviceRepository deviceRepository;
    
    /**
     * Get alert summaries by date
     * GET /api/v2/alerts?date={date}
     * 
     * The device_id is extracted from the "azp" claim in the bearer token.
     * The store_id is then retrieved from the device, and alerts are fetched for that store.
     * 
     * Query Parameters:
     * - date: Date to filter alerts (ISO_DATE format) - optional, defaults to today
     * 
     * Returns list of AlertSummaryDTO (alertId and alertDate) for the specified date and store
     */
    @GetMapping
    public ResponseEntity<List<AlertSummaryDTO>> getAlertSummariesByDate(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        
        // Extract "azp" claim from JWT token (contains device_id/boardId)
        String azp = KeycloakTokenUtils.getClaim("azp", String.class);
        if (azp == null || azp.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .build();
        }
        
        // Get store_id from device by boardId (azp contains the boardId)
        Optional<Long> storeIdOptional = deviceRepository.findStoreIdByBoardId(azp);
        
        if (storeIdOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .build();
        }
        
        Long storeId = storeIdOptional.get();
        
        // Default to today's date if not provided
        if (date == null) {
            date = LocalDate.now();
        }
        
        // Get alert summaries by date and store_id
        List<AlertSummaryDTO> summaries = alertService.getAlertSummariesByDateAndStoreId(date, storeId);
        
        return ResponseEntity.ok(summaries);
    }
}
