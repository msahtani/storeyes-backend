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
public class ChartDataDTO {
    private String period;
    private BigDecimal revenue;
    private BigDecimal charges;
    private BigDecimal profit;
}
