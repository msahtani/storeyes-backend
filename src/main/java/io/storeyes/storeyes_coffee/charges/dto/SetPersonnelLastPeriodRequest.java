package io.storeyes.storeyes_coffee.charges.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class SetPersonnelLastPeriodRequest {

    @NotBlank(message = "Period is required")
    @Pattern(regexp = "week|month", message = "Period must be 'week' or 'month'")
    private String period;
}
