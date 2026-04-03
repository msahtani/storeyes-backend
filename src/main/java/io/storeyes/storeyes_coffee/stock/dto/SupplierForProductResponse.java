package io.storeyes.storeyes_coffee.stock.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplierForProductResponse {
    private Long supplierId;
    private String supplierName;
    private String supplierSku;
    private Boolean isPreferred;
}
