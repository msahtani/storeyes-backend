package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryAnalysisDTO {
    private String category;
    private Double revenue;
    private Integer quantity;
    private Integer transactions;
    private Double percentageOfRevenue;
}

