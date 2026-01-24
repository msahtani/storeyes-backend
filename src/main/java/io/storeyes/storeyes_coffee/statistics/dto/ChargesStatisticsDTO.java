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
public class ChargesStatisticsDTO {
    private BigDecimal totalCharges;
    private BigDecimal totalFixedCharges;
    private BigDecimal totalVariableCharges;
    private Integer itemCount;
    private BigDecimal percentageOfAllCharges; // For variable: % of (fixed + variable)
    private BigDecimal caPercentage; // % of revenue (CA)
    private BigDecimal revenue;
}
