package io.storeyes.storeyes_coffee.alerts.mappers;

import io.storeyes.storeyes_coffee.alerts.dto.AlertDTO;
import io.storeyes.storeyes_coffee.alerts.dto.AlertDetailsDTO;
import io.storeyes.storeyes_coffee.alerts.entities.Alert;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring", uses = {io.storeyes.storeyes_coffee.sales.mappers.SalesMapper.class})
public interface AlertMapper {

    @Mapping(target = "isProcessed", source = "processed")
    @Mapping(target = "humanJudgementComment", ignore = true)
    @Mapping(target = "imageUrl", source = "secondaryImageUrl")
    @Mapping(target = "alertClassName", ignore = true)
    AlertDTO toDTO(Alert alert);

    List<AlertDTO> toDTOList(List<Alert> alerts);

    /**
     * Map Alert entity to AlertDetailsDTO.
     * {@code sales} is populated by the service from {@code coffee_sales_hourly} (the recent
     * orders around the alert), not from the {@code sales} entity relation — so it is ignored here.
     */
    @Mapping(target = "sales", ignore = true)
    @Mapping(target = "isProcessed", source = "processed")
    @Mapping(target = "humanJudgementComment", ignore = true)
    @Mapping(target = "imageUrl", source = "secondaryImageUrl")
    @Mapping(target = "alertClassName", ignore = true)
    AlertDetailsDTO toDetailsDTO(Alert alert);
}

