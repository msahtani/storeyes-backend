package io.storeyes.storeyes_coffee.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.List;
import java.util.Map;

/**
 * Utility class to extract user information from Keycloak JWT tokens
 * Provides convenient methods to access token claims in controllers and services
 */
public class KeycloakTokenUtils {

    /**
     * Get the current JWT token from SecurityContext
     */
    public static Jwt getCurrentJwt() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Jwt) {
            return (Jwt) authentication.getPrincipal();
        }
        return null;
    }

    /**
     * Get the user ID (subject) from the current token
     */
    public static String getUserId() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getSubject() : null;
    }

    /**
     * Get the email from the current token
     */
    public static String getEmail() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaimAsString("email") : null;
    }

    /**
     * Get the preferred username from the current token
     */
    public static String getPreferredUsername() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaimAsString("preferred_username") : null;
    }

    /**
     * Get the given name (first name) from the current token
     */
    public static String getGivenName() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaimAsString("given_name") : null;
    }

    /**
     * Get the family name (last name) from the current token
     */
    public static String getFamilyName() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaimAsString("family_name") : null;
    }

    /**
     * Get the full name from the current token (given_name + family_name)
     */
    public static String getFullName() {
        Jwt jwt = getCurrentJwt();
        if (jwt != null) {
            String givenName = jwt.getClaimAsString("given_name");
            String familyName = jwt.getClaimAsString("family_name");
            if (givenName != null && familyName != null) {
                return givenName + " " + familyName;
            } else if (givenName != null) {
                return givenName;
            } else if (familyName != null) {
                return familyName;
            }
        }
        return null;
    }

    /**
     * Get realm access (realm roles) from the current token
     */
    @SuppressWarnings("unchecked")
    public static Map<String, Object> getRealmAccess() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaimAsMap("realm_access") : null;
    }

    /**
     * Get resource access (client-specific roles) from the current token
     */
    @SuppressWarnings("unchecked")
    public static Map<String, Object> getResourceAccess() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaimAsMap("resource_access") : null;
    }

    /**
     * Get a custom claim from the current token
     */
    public static <T> T getClaim(String claimName, Class<T> clazz) {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaim(claimName) : null;
    }

    /**
     * Get all claims as a map
     */
    public static Map<String, Object> getAllClaims() {
        Jwt jwt = getCurrentJwt();
        return jwt != null ? jwt.getClaims() : null;
    }

    /**
     * Check if the current user has a specific realm role
     */
    @SuppressWarnings("unchecked")
    public static boolean hasRealmRole(String role) {
        Map<String, Object> realmAccess = getRealmAccess();
        if (realmAccess != null) {
            Object rolesObj = realmAccess.get("roles");
            if (rolesObj instanceof java.util.List) {
                List<String> roles = (List<String>) rolesObj;
                return roles.contains(role);
            }
        }
        return false;
    }

    /**
     * Check if the current user has a specific client role
     */
    @SuppressWarnings("unchecked")
    public static boolean hasClientRole(String clientId, String role) {
        Map<String, Object> resourceAccess = getResourceAccess();
        if (resourceAccess != null) {
            Object clientAccessObj = resourceAccess.get(clientId);
            if (clientAccessObj instanceof Map) {
                Map<String, Object> clientAccess = (Map<String, Object>) clientAccessObj;
                Object rolesObj = clientAccess.get("roles");
                if (rolesObj instanceof java.util.List) {
                    List<String> roles = (List<String>) rolesObj;
                    return roles.contains(role);
                }
            }
        }
        return false;
    }
}

