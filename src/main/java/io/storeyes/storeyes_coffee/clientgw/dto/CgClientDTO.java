package io.storeyes.storeyes_coffee.clientgw.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * Minimal local mirror of the upstream client-gw {@code ClientDTO} (st-admin-back), keeping only
 * the fields this app needs to resolve login-time feature access. {@code ignoreUnknown} so the
 * upstream can add fields (id, username, email, ...) without breaking deserialization here.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class CgClientDTO {
    private Long roleId;
    private String roleName;
    private Map<String, Object> featurePolicy;
}
