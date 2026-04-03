package io.storeyes.storeyes_coffee.stock.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplierStockLinkResponse {
    private Long stockProductId;
    private String stockProductName;
    private String supplierSku;
    private Boolean isPreferred;
}
