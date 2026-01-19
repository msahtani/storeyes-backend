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
}
