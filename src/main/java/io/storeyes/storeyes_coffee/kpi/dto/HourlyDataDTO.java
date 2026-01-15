package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HourlyDataDTO {
    private String hour; // Format: "08:00"
    private Double revenue;
    private Integer transactions;
    private Integer itemsSold;
}

