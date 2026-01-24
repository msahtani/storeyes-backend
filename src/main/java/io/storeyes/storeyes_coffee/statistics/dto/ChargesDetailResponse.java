package io.storeyes.storeyes_coffee.statistics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChargesDetailResponse {
    private String period;
    private ChargesStatisticsDTO statistics;
    private List<ChargeItemDTO> fixedCharges;
    private List<ChargeItemDTO> variableCharges;
}
