package io.storeyes.storeyes_coffee.stock.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/** One product in a batch inventory validation. */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ValidateInventoryItemRequest {

    @NotNull(message = "Product ID is required")
    private Long productId;

    /** Target quantity in base unit. */
    @DecimalMin(value = "0", inclusive = true, message = "Quantity must be 0 or positive")
    private BigDecimal quantityInBaseUnit;

    /** Alternative: quantity in counting unit (e.g. 2 kg, 3 bottles). */
    @DecimalMin(value = "0", inclusive = true, message = "Counting quantity must be 0 or positive")
    private BigDecimal countingQuantity;

    /** Amount (MAD) for this adjustment. Optional, default 0. */
    @DecimalMin(value = "0", inclusive = true, message = "Amount must be 0 or positive")
    private BigDecimal amount;
}
