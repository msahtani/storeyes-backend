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
public class RecipeIngredientResponse {
    private Long id;
    private Long articleId;
    private Long productId;
    private String productName;
    private String productUnit;
    private BigDecimal quantity;
    /**
     * Catalog / reference unit price (MAD) from {@code stock_products.unit_price} — used as nominal “buy” price per base unit.
     */
    private BigDecimal productUnitPrice;
    /**
     * Weighted average purchase cost per base unit (MAD) from PURCHASE + ADJUSTMENT movements.
     */
    private BigDecimal averageUnitCost;
    private LocalDateTime createdAt;
}
