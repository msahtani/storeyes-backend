package io.storeyes.storeyes_coffee.statistics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChargeItemDTO {
    private Long id;
    private String name;
    private BigDecimal amount;
    private BigDecimal percentageOfCharges;
    private BigDecimal percentageOfRevenue;
    private String category;
    private String status;
    private String date; // For variable charges
    private String supplier; // For variable charges
}
