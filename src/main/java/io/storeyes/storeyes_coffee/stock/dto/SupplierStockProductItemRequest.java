package io.storeyes.storeyes_coffee.stock.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplierStockProductItemRequest {

    @NotNull
    private Long stockProductId;

    @Size(max = 120)
    private String supplierSku;

    @Builder.Default
    private Boolean isPreferred = false;
}
