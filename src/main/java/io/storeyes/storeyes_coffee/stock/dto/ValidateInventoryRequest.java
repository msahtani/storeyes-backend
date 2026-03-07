package io.storeyes.storeyes_coffee.stock.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/** Request to validate inventory (batch: create session, snapshots, ADJUSTMENT movements). */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ValidateInventoryRequest {

    @NotEmpty(message = "At least one item is required")
    @Valid
    private List<ValidateInventoryItemRequest> items;
}
