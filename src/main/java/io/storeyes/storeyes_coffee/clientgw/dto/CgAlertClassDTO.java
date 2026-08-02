package io.storeyes.storeyes_coffee.clientgw.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Local mirror of the upstream client-gw {@code AlertClassDTO} (st-admin-back,
 * {@code GET /client-gw/alert-classes}) — global classes plus the calling store's own.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class CgAlertClassDTO {
    private Long id;
    private String name;
    private Long storeId;
}
