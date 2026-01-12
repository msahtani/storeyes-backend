package io.storeyes.storeyes_coffee.store.mappers;

import io.storeyes.storeyes_coffee.store.dto.StoreDTO;
import io.storeyes.storeyes_coffee.store.entities.Store;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface StoreMapper {
    
    StoreDTO toDTO(Store store);
    
    List<StoreDTO> toDTOList(List<Store> stores);
}

