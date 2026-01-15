package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyReportDTO {
    private String date; // Format: "2024-01-15"
    private String businessName;
    private RevenueDTO revenue;
    private List<HourlyDataDTO> hourlyData;
    private List<TopProductDTO> topProductsByQuantity;
    private List<TopProductDTO> topProductsByRevenue;
    private List<CategoryAnalysisDTO> categoryAnalysis;
    private List<StaffPerformanceDTO> staffPerformance;
    private List<PeakPeriodDTO> peakPeriods;
    private InsightsDTO insights;
}

