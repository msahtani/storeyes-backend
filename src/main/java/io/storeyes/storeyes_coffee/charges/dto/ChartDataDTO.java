package io.storeyes.storeyes_coffee.charges.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChartDataDTO {
    private String period;
    private BigDecimal amount;
}
