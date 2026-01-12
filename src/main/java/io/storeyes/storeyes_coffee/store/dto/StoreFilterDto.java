package io.storeyes.storeyes_coffee.store.dto;

import io.storeyes.storeyes_coffee.store.entities.StoreStatus;
import lombok.Data;

@Data
public class StoreFilterDto {
    
    private String code;
    private String name;
    private String city;
    private String type;
    private String address;
    private StoreStatus status;
    
    // Future filters can be added here
    // private String region;
    // private Boolean active;
    // private LocalDateTime createdAfter;
    // etc.
}

