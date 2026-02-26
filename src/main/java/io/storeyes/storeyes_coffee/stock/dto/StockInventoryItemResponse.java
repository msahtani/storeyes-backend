package io.storeyes.storeyes_coffee.stock.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Product with current stock quantity and total value (based on purchase amounts, not product.unitPrice).
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StockInventoryItemResponse {
    private Long productId;
    private String productName;
    private String unit;
    private Long subCategoryId;
    private String subCategoryName;
    private BigDecimal currentQuantity;
    private BigDecimal totalPurchaseAmount;
    private BigDecimal averageUnitCost;
    private BigDecimal totalValue;
}
