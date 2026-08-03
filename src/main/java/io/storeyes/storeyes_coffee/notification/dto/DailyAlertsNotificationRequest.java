package io.storeyes.storeyes_coffee.notification.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class DailyAlertsNotificationRequest {

    @NotNull
    private LocalDate date;

    @NotNull
    @Min(0)
    private Integer count;
}
