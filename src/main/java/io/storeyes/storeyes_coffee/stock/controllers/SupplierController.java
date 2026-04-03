package io.storeyes.storeyes_coffee.stock.controllers;

import io.storeyes.storeyes_coffee.stock.dto.*;
import io.storeyes.storeyes_coffee.stock.services.SupplierService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/stock/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> listSuppliers(@RequestParam(required = false) String search) {
        List<SupplierSummaryResponse> data = supplierService.listSuppliers(search);
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Suppliers retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getSupplier(@PathVariable Long id) {
        SupplierDetailResponse data = supplierService.getSupplierById(id);
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Supplier retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createSupplier(@Valid @RequestBody CreateSupplierRequest request) {
        SupplierDetailResponse data = supplierService.createSupplier(request);
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Supplier created successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateSupplier(
            @PathVariable Long id,
            @Valid @RequestBody UpdateSupplierRequest request) {
        SupplierDetailResponse data = supplierService.updateSupplier(id, request);
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Supplier updated successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deactivateSupplier(@PathVariable Long id) {
        supplierService.deactivateSupplier(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    @PutMapping("/{id}/stock-products")
    public ResponseEntity<Map<String, Object>> setStockProducts(
            @PathVariable Long id,
            @Valid @RequestBody SetSupplierStockProductsRequest request) {
        SupplierDetailResponse data = supplierService.setSupplierStockProducts(id, request);
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Supplier stock product links updated successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Suppliers linked to a stock product (same store).
     */
    @GetMapping("/for-stock-product/{stockProductId}")
    public ResponseEntity<Map<String, Object>> listForStockProduct(@PathVariable Long stockProductId) {
        List<SupplierForProductResponse> data = supplierService.listSuppliersForStockProduct(stockProductId);
        Map<String, Object> response = new HashMap<>();
        response.put("data", data);
        response.put("message", "Suppliers for stock product retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }
}
