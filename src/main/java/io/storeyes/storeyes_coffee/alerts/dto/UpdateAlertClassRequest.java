package io.storeyes.storeyes_coffee.alerts.dto;

import lombok.Data;

@Data
public class UpdateAlertClassRequest {

    /** Null to unclassify the alert. */
    private Long alertClassId;
}
