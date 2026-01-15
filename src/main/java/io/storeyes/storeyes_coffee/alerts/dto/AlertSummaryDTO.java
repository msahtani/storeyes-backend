package io.storeyes.storeyes_coffee.alerts.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AlertSummaryDTO {
    private Long alertId;
    private LocalDateTime alertDate;
}

