package io.storeyes.storeyes_coffee.clientgw.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * Local mirror of the upstream client-gw {@code RoleSummaryDTO} (st-admin-back,
 * {@code GET /client-gw/roles}) — a role visible to a store (global or that store's own custom
 * role) with its featurePolicy.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class CgRoleDTO {
    private Long id;
    private String name;
    private Long storeId;
    private Map<String, Object> featurePolicy;
}
