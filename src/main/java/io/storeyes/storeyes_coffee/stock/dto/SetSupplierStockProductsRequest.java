package io.storeyes.storeyes_coffee.stock.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SetSupplierStockProductsRequest {

    @NotNull
    @Valid
    private List<SupplierStockProductItemRequest> items;
}
