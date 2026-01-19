package io.storeyes.storeyes_coffee.charges.dto;

import jakarta.validation.constraints.Positive;
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
    @Size(max = 200, message = "Name must not exceed 200 characters")
    private String name;
    
    @Positive(message = "Amount must be positive if provided")
    private BigDecimal amount;
    
    private LocalDate date;
    
    @Size(max = 50, message = "Category must not exceed 50 characters")
    private String category;
    
    @Size(max = 200, message = "Supplier must not exceed 200 characters")
    private String supplier;
    
    @Size(max = 1000, message = "Notes must not exceed 1000 characters")
    private String notes;
    
    @Size(max = 500, message = "Purchase order URL must not exceed 500 characters")
    private String purchaseOrderUrl;
}
