package io.storeyes.storeyes_coffee.stock.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplierDetailResponse {
    private Long id;
    private String name;
    private String code;
    private String email;
    private String phone;
    private String notes;
    private Boolean isActive;
    private long linkedProductCount;
    private List<SupplierStockLinkResponse> stockProducts;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
