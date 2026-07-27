package io.storeyes.storeyes_coffee.clientgw.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Local mirror of the upstream client-gw {@code FeatureSetSummaryDTO} (st-admin-back) — the
 * features a store's Pack grants.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class CgFeatureSetDTO {
    private Long id;
    private String code;
    private String name;
}
