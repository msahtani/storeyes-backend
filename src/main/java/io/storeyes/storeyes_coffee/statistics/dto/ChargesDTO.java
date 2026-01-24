package io.storeyes.storeyes_coffee.statistics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChargesDTO {
    private List<ChargeItemDTO> fixed;
    private List<ChargeItemDTO> variable;
}
