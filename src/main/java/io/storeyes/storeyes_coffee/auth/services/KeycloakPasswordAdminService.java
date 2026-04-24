package io.storeyes.storeyes_coffee.auth.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.storeyes.storeyes_coffee.auth.config.KeycloakAdminProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * Sets a user's password via Keycloak Admin REST API (OAuth2 client_credentials).
 * Configure {@link KeycloakAdminProperties} under {@code app.keycloak-admin.*}.
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class KeycloakPasswordAdminService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final KeycloakAdminProperties adminProperties;

    @Value("${spring.security.oauth2.resourceserver.jwt.issuer-uri}")
    private String keycloakIssuerUri;

    public boolean isEnabled() {
        return adminProperties.isPasswordResetAdminReady();
    }

    public void resetPassword(String keycloakUserId, String newPassword) {
        if (!isEnabled()) {
            throw new IllegalStateException("Keycloak admin API is not configured");
        }
        String base = keycloakServerBase();
        String usersRealm = resolveUsersRealm();
        String token = fetchServiceAccountToken(base);
        String url = base + "/admin/realms/" + usersRealm + "/users/" + keycloakUserId + "/reset-password";

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity = new HttpEntity<>(resetPasswordJson(newPassword), headers);
        try {
            restTemplate.exchange(url, HttpMethod.PUT, entity, Void.class);
        } catch (HttpClientErrorException e) {
            log.warn("Keycloak reset-password failed: {} {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw e;
        }
    }

    private String resetPasswordJson(String newPassword) {
        try {
            return objectMapper.writeValueAsString(
                    Map.of("type", "password", "value", newPassword, "temporary", false));
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Cannot serialize reset-password body", e);
        }
    }

    private String fetchServiceAccountToken(String base) {
        String tokenUrl = base + "/realms/" + adminProperties.getAuthRealm() + "/protocol/openid-connect/token";
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "client_credentials");
        form.add("client_id", adminProperties.getClientId());
        form.add("client_secret", adminProperties.getClientSecret());
        ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                tokenUrl,
                HttpMethod.POST,
                new HttpEntity<>(form, headers),
                new ParameterizedTypeReference<Map<String, Object>>() {});
        Map<String, Object> body = response.getBody();
        if (body == null || body.get("access_token") == null) {
            throw new IllegalStateException("Keycloak admin token response missing access_token");
        }
        return (String) body.get("access_token");
    }

    private String keycloakServerBase() {
        String override = adminProperties.getServerUrl();
        if (override != null && !override.isBlank()) {
            String u = override.trim();
            return u.endsWith("/") ? u.substring(0, u.length() - 1) : u;
        }
        int idx = keycloakIssuerUri.indexOf("/realms/");
        if (idx <= 0) {
            return keycloakIssuerUri.endsWith("/")
                    ? keycloakIssuerUri.substring(0, keycloakIssuerUri.length() - 1)
                    : keycloakIssuerUri;
        }
        return keycloakIssuerUri.substring(0, idx);
    }

    private String resolveUsersRealm() {
        String configured = adminProperties.getUsersRealm();
        if (configured != null && !configured.isBlank()) {
            return configured.trim();
        }
        return extractRealm(keycloakIssuerUri);
    }

    static String extractRealm(String issuerUri) {
        int i = issuerUri.indexOf("/realms/");
        if (i < 0) {
            throw new IllegalArgumentException("issuer-uri must contain /realms/{realm}");
        }
        String tail = issuerUri.substring(i + "/realms/".length());
        int slash = tail.indexOf('/');
        return slash > 0 ? tail.substring(0, slash) : tail;
    }
}
