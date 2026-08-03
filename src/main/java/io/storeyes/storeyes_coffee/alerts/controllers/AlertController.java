package io.storeyes.storeyes_coffee.alerts.controllers;

import io.storeyes.storeyes_coffee.alerts.dto.AlertDTO;
import io.storeyes.storeyes_coffee.alerts.dto.AlertDetailsDTO;
import io.storeyes.storeyes_coffee.alerts.dto.AlertSettingsDTO;
import io.storeyes.storeyes_coffee.alerts.dto.UpdateAlertClassRequest;
import io.storeyes.storeyes_coffee.alerts.dto.UpdateHumanJudgementRequest;
import io.storeyes.storeyes_coffee.alerts.entities.Alert;
import io.storeyes.storeyes_coffee.alerts.entities.AlertType;
import io.storeyes.storeyes_coffee.alerts.mappers.AlertMapper;
import io.storeyes.storeyes_coffee.alerts.services.AlertService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
public class AlertController {
    
    private final AlertService alertService;
    private final AlertMapper alertMapper;
    
    @GetMapping
    public ResponseEntity<List<AlertDTO>> getAlertsByDate(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime date,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(required = false) Boolean unprocessed,
            @RequestParam(required = false) Boolean returnType,
            @RequestParam(required = false) AlertType alertType) {
        LocalDateTime effectiveDate = startDate != null ? startDate : date;
        List<Alert> alerts = alertService.getAlertsByDate(effectiveDate, endDate, unprocessed, returnType, alertType);
        List<AlertDTO> alertDTOs = alertMapper.toDTOList(alerts);
        alertService.enrichAlertClassNames(alerts, alertDTOs);
        return ResponseEntity.ok(alertDTOs);
    }

    /**
     * Per-store alert-type visibility for the current user's selected store.
     * GET /api/alerts/settings
     */
    @GetMapping("/settings")
    public ResponseEntity<AlertSettingsDTO> getAlertSettings() {
        return ResponseEntity.ok(alertService.getAlertSettings());
    }

    /**
     * Update human judgement for an alert
     * PATCH /api/alerts/{id}/human-judgement
     */
    @PatchMapping("/{id}/human-judgement")
    public ResponseEntity<Void> updateHumanJudgement(
            @PathVariable Long id,
            @Valid @RequestBody UpdateHumanJudgementRequest request) {
        boolean updated = alertService.updateHumanJudgement(id, request.getHumanJudgement());

        return updated
                ? ResponseEntity.noContent().build()
                : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }
    
    /**
     * Assign (or clear, when {@code alertClassId} is null) an alert's classification tag.
     * PATCH /api/alerts/{id}/alert-class
     */
    @PatchMapping("/{id}/alert-class")
    public ResponseEntity<Void> updateAlertClass(
            @PathVariable Long id,
            @RequestBody UpdateAlertClassRequest request) {
        boolean updated = alertService.updateAlertClass(id, request.getAlertClassId());

        return updated
                ? ResponseEntity.noContent().build()
                : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }

    /**
     * Get alert details with sales by ID.
     * GET /api/alerts/{id}/details
     * Uses JOIN FETCH to avoid N+1 query problem.
     *
     * <p>For demo stores, pass {@code ?date=} (ISO date) to have the returned alert's
     * {@code alertDate} rewritten to that date (time-of-day is preserved).
     * If omitted for a demo store, today's date is used.</p>
     */
    @GetMapping("/{id}/details")
    public ResponseEntity<AlertDetailsDTO> getAlertDetailsWithSales(
            @PathVariable Long id,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        AlertDetailsDTO alertDetails = alertService.getAlertDetailsWithSales(id, date);
        return ResponseEntity.ok(alertDetails);
    }
}

