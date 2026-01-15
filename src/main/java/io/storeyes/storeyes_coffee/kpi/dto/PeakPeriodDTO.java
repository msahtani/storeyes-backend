package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PeakPeriodDTO {
    private String period; // e.g., "Afternoon (2-4 PM)"
    private String timeRange; // e.g., "14:00-16:00"
    private Double revenue;
    private Integer transactions;
    private Integer itemsSold;
    private Double share; // Percentage of total revenue
    private String status; // "peak", "moderate", "low"
}

