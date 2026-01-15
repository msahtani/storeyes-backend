package io.storeyes.storeyes_coffee.kpi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TopProductDTO {
    private Integer rank;
    private String name;
    private Integer quantity; // For topProductsByQuantity
    private Double revenue; // For topProductsByRevenue
}

