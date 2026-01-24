package io.storeyes.storeyes_coffee.statistics.controllers;

import io.storeyes.storeyes_coffee.statistics.dto.ChargesDetailResponse;
import io.storeyes.storeyes_coffee.statistics.dto.StatisticsResponse;
import io.storeyes.storeyes_coffee.statistics.services.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
public class StatisticsController {

    private final StatisticsService statisticsService;

    /**
     * Get comprehensive statistics for a specific period
     * GET /api/statistics?period={period}&date={date}
     * 
     * @param period Period type: "day", "week", or "month"
     * @param date Date in format:
     *   - day: YYYY-MM-DD (e.g., "2024-01-15")
     *   - week: YYYY-MM-DD (Monday date of the week, e.g., "2024-01-15")
     *   - month: YYYY-MM (e.g., "2024-01")
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getStatistics(
            @RequestParam String period,
            @RequestParam String date) {
        
        try {
            StatisticsResponse response = statisticsService.getStatistics(period, date);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("data", response);
            
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", createErrorResponse("STATISTICS_ERROR", e.getMessage()));
            
            int statusCode = 400;
            String message = e.getMessage();
            if (message != null) {
                String lowerMessage = message.toLowerCase();
                if (lowerMessage.contains("not found") || lowerMessage.contains("no data")) {
                    statusCode = 404;
                } else if (lowerMessage.contains("unavailable") || lowerMessage.contains("cannot be retrieved")) {
                    statusCode = 503;
                }
            }
            
            return ResponseEntity.status(statusCode).body(errorResponse);
        }
    }

    /**
     * Get detailed charges breakdown for a specific period
     * GET /api/statistics/charges?period={period}&month={month}&week={week}
     * 
     * @param period Period type: "week" or "month"
     * @param month Month key in format YYYY-MM (e.g., "2024-01")
     * @param week Week key in format YYYY-MM-DD (Monday date, required for week period)
     */
    @GetMapping("/charges")
    public ResponseEntity<Map<String, Object>> getChargesDetail(
            @RequestParam String period,
            @RequestParam String month,
            @RequestParam(required = false) String week) {
        
        try {
            ChargesDetailResponse response = statisticsService.getChargesDetail(period, month, week);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("data", response);
            
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", createErrorResponse("STATISTICS_ERROR", e.getMessage()));
            
            int statusCode = 400;
            String message = e.getMessage();
            if (message != null) {
                String lowerMessage = message.toLowerCase();
                if (lowerMessage.contains("not found") || lowerMessage.contains("no data")) {
                    statusCode = 404;
                } else if (lowerMessage.contains("unavailable") || lowerMessage.contains("cannot be retrieved")) {
                    statusCode = 503;
                }
            }
            
            return ResponseEntity.status(statusCode).body(errorResponse);
        }
    }

    /**
     * Create error response object
     */
    private Map<String, Object> createErrorResponse(String code, String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("code", code);
        error.put("message", message != null ? message : "An error occurred");
        error.put("details", new HashMap<>());
        return error;
    }
}
