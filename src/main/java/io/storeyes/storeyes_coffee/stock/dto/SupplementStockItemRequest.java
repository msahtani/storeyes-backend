package io.storeyes.storeyes_coffee.stock.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * One product in a stock supplement operation (incoming goods outside purchase flow).
 * Represents a POSITIVE delta to add (quantity + cost for this incoming batch).
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplementStockItemRequest {

    @NotNull(message = "Product ID is required")
    private Long productId;

    /** Delta quantity to add, in base unit (e.g. grams, ml, pieces). */
    @DecimalMin(value = "0", inclusive = false, message = "Delta quantity must be positive")
    private BigDecimal deltaQuantityInBaseUnit;

    /** Alternative: delta in counting unit (e.g. 2 bottles, 3 kg bags). */
    @DecimalMin(value = "0", inclusive = false, message = "Delta counting quantity must be positive")
    private BigDecimal deltaCountingQuantity;

    /** Total purchase cost (MAD) for this incoming batch. Required when delta quantity is provided. */
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0", inclusive = true, message = "Amount must be 0 or positive")
    private BigDecimal amount;
}
