package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InsightsDTO {
    private PeakHourDTO peakHour;
    private BestSellingProductDTO bestSellingProduct;
    private Double highestValueTransaction;
    private BusiestPeriodDTO busiestPeriod;
    private RevenueComparisonDTO revenueComparison;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class PeakHourDTO {
        private String time;
        private Double revenue;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class BestSellingProductDTO {
        private String name;
        private Integer quantity;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class BusiestPeriodDTO {
        private String period;
        private Integer transactions;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RevenueComparisonDTO {
        private Double vsPreviousDay; // Percentage change
        private Double vsPreviousWeek; // Percentage change
    }
}

