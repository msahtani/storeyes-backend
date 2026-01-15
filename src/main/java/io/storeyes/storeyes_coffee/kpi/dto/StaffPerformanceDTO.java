package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StaffPerformanceDTO {
    private String name;
    private Double revenue;
    private Integer transactions;
    private Double avgValue;
    private Double share; // Percentage of total revenue
}

