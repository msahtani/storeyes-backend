package io.storeyes.storeyes_coffee.charges.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VariableChargeUpdateRequest {

    private LocalDate date;

    private Long mainCategoryId;

    @Size(max = 200, message = "Name must not exceed 200 characters")
    private String name;

    @DecimalMin(value = "0", inclusive = true, message = "Amount must be 0 or positive when provided")
    private BigDecimal amount;

    private Long subCategoryId;

    private Long productId;

    @DecimalMin(value = "0", inclusive = false, message = "Quantity must be positive when provided")
    private BigDecimal quantity;

    @DecimalMin(value = "0", inclusive = true, message = "Unit price must be 0 or positive when provided")
    private BigDecimal unitPrice;

    @Size(max = 200, message = "Supplier must not exceed 200 characters")
    private String supplier;

    @Size(max = 1000, message = "Notes must not exceed 1000 characters")
    private String notes;

    @Size(max = 500, message = "Purchase order URL must not exceed 500 characters")
    private String purchaseOrderUrl;

    /**
     * When true and the charge has a stock product: set {@code stock_products.unit_price}
     * to this charge's unit price after the update.
     */
    private Boolean updateStockProductUnitPrice;
}
