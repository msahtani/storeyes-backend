package io.storeyes.storeyes_coffee.alerts.dto;

import io.storeyes.storeyes_coffee.alerts.entities.AlertSource;
import io.storeyes.storeyes_coffee.alerts.entities.AlertType;
import io.storeyes.storeyes_coffee.alerts.entities.HumanJudgement;
import io.storeyes.storeyes_coffee.sales.dto.SalesDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AlertDetailsDTO {

    private Long id;
    private LocalDateTime alertDate;
    private String mainVideoUrl;
    private String productName;
    private String imageUrl;
    private boolean isProcessed;
    private String secondaryVideoUrl;
    private HumanJudgement humanJudgement;
    private String humanJudgementComment;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<SalesDTO> sales;
    private AlertType alertType;
    /** Name of the alert's classification tag, resolved from the client-gw alert-classes lookup; null when unclassified. */
    private String alertClassName;
    private AlertSource alertSource;
}

