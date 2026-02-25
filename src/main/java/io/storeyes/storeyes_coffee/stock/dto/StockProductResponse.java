package io.storeyes.storeyes_coffee.stock.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StockProductResponse {
    private Long id;
    private String name;
    private String unit;
    private BigDecimal unitPrice;
    private BigDecimal minimalThreshold;
    private Long subCategoryId;
    private String subCategoryName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
