package io.storeyes.storeyes_coffee.stock.dto;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateSupplierRequest {

    @Size(max = 255)
    private String name;

    @Size(max = 100)
    private String code;

    @Size(max = 255)
    private String email;

    @Size(max = 100)
    private String phone;

    @Size(max = 2000)
    private String notes;

    private Boolean isActive;
}
