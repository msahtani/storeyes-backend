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
    private LocalDateTime createdAt;
}
