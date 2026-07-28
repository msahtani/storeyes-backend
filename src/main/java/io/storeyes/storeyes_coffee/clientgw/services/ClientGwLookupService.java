package io.storeyes.storeyes_coffee.clientgw.services;

import io.storeyes.storeyes_coffee.clientgw.config.ClientGwProperties;
import io.storeyes.storeyes_coffee.clientgw.dto.CgFeatureSetDTO;
import io.storeyes.storeyes_coffee.clientgw.dto.CgPackLayoutDTO;
import io.storeyes.storeyes_coffee.clientgw.dto.CgRoleDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.util.List;

/**
 * Server-side reads from the upstream client-gw gateway (panel.storeyes.io, st-admin-back),
 * used to enrich the login response with per-store feature access. Unlike
 * {@link io.storeyes.storeyes_coffee.proxy.ClientGwProxyController}, which streams raw bytes
 * back to the frontend, this consumes the upstream responses internally.
 * <p>
 * Every method fails soft: a down/slow/erroring upstream degrades the caller's data to
 * empty rather than propagating an exception, so login itself never breaks because of this
 * gateway.
 */
@Service
@Slf4j
public class ClientGwLookupService {

    private static final String API_KEY_HEADER = "X-API-KEY";
    private static final String STORE_ID_HEADER = "X-STORE-ID";

    private final RestTemplate restTemplate;
    private final ClientGwProperties clientGwProperties;

    public ClientGwLookupService(
            @Qualifier("clientGwRestTemplate") RestTemplate restTemplate,
            ClientGwProperties clientGwProperties) {
        this.restTemplate = restTemplate;
        this.clientGwProperties = clientGwProperties;
    }

    /**
     * The roles visible to the given store — global roles plus that store's own custom roles,
     * each with its featurePolicy. Unlike a per-user "client" membership (a separate portal-user
     * concept in st-admin-back that app users are never provisioned into), this only requires the
     * role itself to exist upstream, which is the assumption that actually holds in practice.
     */
    public List<CgRoleDTO> fetchRoles(Long storeId) {
        URI uri = URI.create(clientGwProperties.getBaseUrl() + "/roles");
        try {
            ResponseEntity<List<CgRoleDTO>> response = restTemplate.exchange(
                    uri, HttpMethod.GET, new HttpEntity<>(headers(storeId)),
                    new ParameterizedTypeReference<>() {
                    });
            List<CgRoleDTO> body = response.getBody();
            return body != null ? body : List.of();
        } catch (HttpStatusCodeException e) {
            log.warn("client-gw roles lookup failed (store {}): {} {}",
                    storeId, e.getStatusCode(), e.getResponseBodyAsString());
            return List.of();
        } catch (ResourceAccessException e) {
            log.warn("client-gw roles lookup unreachable (store {}): {}", storeId, e.getMessage());
            return List.of();
        }
    }

    /** The FeatureSets granted by the given store's Pack, or empty if none/unreachable. */
    public List<CgFeatureSetDTO> fetchFeatureSets(Long storeId) {
        URI uri = URI.create(clientGwProperties.getBaseUrl() + "/feature-sets");
        try {
            ResponseEntity<List<CgFeatureSetDTO>> response = restTemplate.exchange(
                    uri, HttpMethod.GET, new HttpEntity<>(headers(storeId)),
                    new ParameterizedTypeReference<>() {
                    });
            List<CgFeatureSetDTO> body = response.getBody();
            return body != null ? body : List.of();
        } catch (HttpStatusCodeException e) {
            log.warn("client-gw feature-sets lookup failed (store {}): {} {}",
                    storeId, e.getStatusCode(), e.getResponseBodyAsString());
            return List.of();
        } catch (ResourceAccessException e) {
            log.warn("client-gw feature-sets lookup unreachable (store {}): {}", storeId, e.getMessage());
            return List.of();
        }
    }

    /** The given store's Pack home screen / nav bar layout, or null mobileLayout if none/unreachable. */
    public CgPackLayoutDTO fetchPackLayout(Long storeId) {
        URI uri = URI.create(clientGwProperties.getBaseUrl() + "/pack");
        try {
            ResponseEntity<CgPackLayoutDTO> response = restTemplate.exchange(
                    uri, HttpMethod.GET, new HttpEntity<>(headers(storeId)), CgPackLayoutDTO.class);
            CgPackLayoutDTO body = response.getBody();
            return body != null ? body : new CgPackLayoutDTO();
        } catch (HttpStatusCodeException e) {
            log.warn("client-gw pack layout lookup failed (store {}): {} {}",
                    storeId, e.getStatusCode(), e.getResponseBodyAsString());
            return new CgPackLayoutDTO();
        } catch (ResourceAccessException e) {
            log.warn("client-gw pack layout lookup unreachable (store {}): {}", storeId, e.getMessage());
            return new CgPackLayoutDTO();
        }
    }

    private HttpHeaders headers(Long storeId) {
        HttpHeaders headers = new HttpHeaders();
        headers.set(API_KEY_HEADER, clientGwProperties.getApiKey());
        headers.set(STORE_ID_HEADER, String.valueOf(storeId));
        return headers;
    }
}
