package io.storeyes.storeyes_coffee.stock.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateStockProductRequest {

    @NotBlank(message = "Name is required")
    @Size(max = 255, message = "Name must not exceed 255 characters")
    private String name;

    @NotNull(message = "Sub-category is required")
    private Long subCategoryId;

    @NotBlank(message = "Unit is required")
    @Size(max = 50, message = "Unit must not exceed 50 characters")
    private String unit;

    @NotNull(message = "Unit price is required")
    @DecimalMin(value = "0", inclusive = false, message = "Unit price must be positive")
    private BigDecimal unitPrice;

    @DecimalMin(value = "0", inclusive = true, message = "Minimal threshold must be 0 or positive")
    private BigDecimal minimalThreshold; // optional; default 0 in service

    @Size(max = 50, message = "Counting unit must not exceed 50 characters")
    private String countingUnit;

    @DecimalMin(value = "0", inclusive = false, message = "Base per counting unit must be positive when set")
    private BigDecimal basePerCountingUnit; // optional; for human counting (e.g. plateau = 30 pieces)
}
