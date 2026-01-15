package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RevenueDTO {
    private Double totalTTC;
    private Double totalHT;
    private Integer transactions;
    private Double avgTransactionValue;
    private Double revenuePerTransaction;
}

