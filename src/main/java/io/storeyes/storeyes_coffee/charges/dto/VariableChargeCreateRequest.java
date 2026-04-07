package io.storeyes.storeyes_coffee.charges.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
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
public class VariableChargeCreateRequest {

    @NotNull(message = "Date is required")
    private LocalDate date;

    @NotNull(message = "Main category is required")
    private Long mainCategoryId;

    /** For non-Stock main category (e.g. Achat exceptionnel): required. For Stock with product: optional (derived from product). */
    @Size(max = 200, message = "Name must not exceed 200 characters")
    private String name;

    /** For non-Stock: required. For Stock with product: optional (computed from quantity × unit_price if not sent). */
    @DecimalMin(value = "0", inclusive = true, message = "Amount must be 0 or positive")
    private BigDecimal amount;

    /** For Stock path: sub-category (e.g. Raw materials, Hygiene). */
    private Long subCategoryId;

    /** For Stock path: product from stock_products. */
    private Long productId;

    /** For Stock path: quantity when product is selected. */
    @DecimalMin(value = "0", inclusive = false, message = "Quantity must be positive when provided")
    private BigDecimal quantity;

    /** For Stock path: unit price (optional override from product). */
    @DecimalMin(value = "0", inclusive = true, message = "Unit price must be 0 or positive when provided")
    private BigDecimal unitPrice;

    @Size(max = 200, message = "Supplier must not exceed 200 characters")
    private String supplier;

    @Size(max = 1000, message = "Notes must not exceed 1000 characters")
    private String notes;

    @Size(max = 500, message = "Purchase order URL must not exceed 500 characters")
    private String purchaseOrderUrl;

    /**
     * When true and this is a stock purchase with a product: update {@code stock_products.unit_price}
     * to match this charge's purchase unit price after saving the charge.
     */
    private Boolean updateStockProductUnitPrice;
}
