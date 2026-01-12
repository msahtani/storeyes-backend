package io.storeyes.storeyes_coffee.store.dto;

import io.storeyes.storeyes_coffee.store.entities.StoreStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateStoreRequest {
    
    @NotNull(message = "Code is required")
    private String code;
    
    @NotNull(message = "Name is required")
    private String name;
    
    @NotNull(message = "Address is required")
    private String address;
    
    @NotNull(message = "Coordinates are required")
    private double[] coordinates;
    
    @NotNull(message = "City is required")
    private String city;
    
    @NotNull(message = "Type is required")
    private String type;
    
    private StoreStatus status;
}

