package io.storeyes.storeyes_coffee.product.controllers;

import io.storeyes.storeyes_coffee.product.dto.SalesByStoreDateDTO;
import io.storeyes.storeyes_coffee.product.entities.SalesProduct;
import io.storeyes.storeyes_coffee.product.repositories.SalesProductRepository;
import io.storeyes.storeyes_coffee.store.repositories.StoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final SalesProductRepository salesProductRepository;
    private final StoreRepository storeRepository;

    /**
     * Get list of sales by store and date.
     * GET /api/products/sales?storeId=1&date=2025-01-15
     *
     * @param storeId Store ID (required)
     * @param date    Sale date in ISO format (required)
     * @return List of {id, productCode, productName, quantity, price, totalPrice}
     */
    @GetMapping("/sales")
    public ResponseEntity<List<SalesByStoreDateDTO>> getSalesByStoreAndDate(
            @RequestParam Long storeId,
            @RequestParam LocalDate date) {

        if (!storeRepository.existsById(storeId)) {
            return ResponseEntity.notFound().build();
        }

        List<SalesProduct> salesProducts = salesProductRepository.findByStoreIdAndDate(storeId, date);
        List<SalesByStoreDateDTO> dtos = salesProducts.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    private SalesByStoreDateDTO toDTO(SalesProduct sp) {
        return SalesByStoreDateDTO.builder()
                .id(sp.getId())
                .productCode(sp.getProduct() != null ? sp.getProduct().getCode() : null)
                .productName(sp.getProduct() != null ? sp.getProduct().getName() : null)
                .quantity(sp.getQuantity())
                .price(sp.getPrice())
                .totalPrice(sp.getTotalPrice())
                .build();
    }
}
