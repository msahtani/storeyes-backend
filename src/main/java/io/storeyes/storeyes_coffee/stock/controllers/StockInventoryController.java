package io.storeyes.storeyes_coffee.stock.controllers;

import io.storeyes.storeyes_coffee.stock.dto.StockInventoryItemResponse;
import io.storeyes.storeyes_coffee.stock.services.StockMovementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/stock/inventory")
@RequiredArgsConstructor
public class StockInventoryController {

    private final StockMovementService stockMovementService;

    /**
     * Inventory summary: products with current quantity and total value (based on purchase amounts).
     * GET /api/stock/inventory
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getInventorySummary() {
        List<StockInventoryItemResponse> items = stockMovementService.getInventorySummary();
        Map<String, Object> response = new HashMap<>();
        response.put("data", items);
        response.put("message", "Inventory summary retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }
}
