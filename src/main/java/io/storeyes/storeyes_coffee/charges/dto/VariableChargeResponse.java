package io.storeyes.storeyes_coffee.charges.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VariableChargeResponse {
    private Long id;
    private String name;
    private BigDecimal amount;
    private LocalDate date;
    private String category;
    private String supplier;
    private String notes;
    private String purchaseOrderUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /** New fields: main category */
    private Long mainCategoryId;
    private String mainCategoryName;

    /** Sub-category (e.g. Raw materials, Bar). */
    private Long subCategoryId;
    private String subCategoryName;

    /** Product when Stock path. */
    private Long productId;
    private String productName;

    private BigDecimal quantity;
    private BigDecimal unitPrice;

    /** Unit for display (counting unit preferred): kg, L, piece, etc. */
    private String unit;
    private String countingUnit;
}
