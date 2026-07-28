package io.storeyes.storeyes_coffee.clientgw.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * Local mirror of the upstream client-gw {@code PackLayoutDTO} (st-admin-back) — the
 * home screen / nav bar layout configured on a store's Pack. Null {@code mobileLayout}
 * if the store has no pack assigned or the pack has no layout configured yet.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class CgPackLayoutDTO {
    private Map<String, Object> mobileLayout;
}
