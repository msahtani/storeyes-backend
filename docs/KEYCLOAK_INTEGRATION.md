# Keycloak Integration Guide

This document describes how Keycloak authentication is implemented in the backend API.

## Overview

The backend uses Spring Security with OAuth2 Resource Server to validate JWT tokens issued by Keycloak. All protected endpoints require a valid Bearer token in the `Authorization` header.

## Configuration

### Application Properties

Keycloak configuration is defined in `application.yaml`:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://15.216.37.183/realms/storeyes
          audience: storeyes-mobile
```

- **issuer-uri**: The Keycloak realm issuer URI. Spring Boot automatically configures the JWKS endpoint for public key retrieval.
- **audience**: The expected audience (client ID) in the JWT token.

These values can be overridden using environment variables:
- `KEYCLOAK_ISSUER_URI`
- `KEYCLOAK_AUDIENCE`

## Security Configuration

### Protected Endpoints

All endpoints under `/api/**` require authentication by default. The security configuration is defined in `SecurityConfig.java`.

### CORS Configuration

CORS is enabled to allow requests from mobile applications and other clients. The configuration allows:
- All origins (`*`)
- Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
- Headers: Content-Type, Authorization, X-Requested-With

**Note**: In production, consider restricting allowed origins to specific domains.

## Token Validation

The backend validates JWT tokens by:
1. Extracting the token from the `Authorization: Bearer <token>` header
2. Validating the token signature against Keycloak's public keys (fetched from JWKS endpoint)
3. Verifying the token issuer matches the configured realm
4. Checking token expiration
5. Extracting user information and roles from token claims

## Accessing User Information in Controllers

Use `KeycloakTokenUtils` to extract user information from the authenticated JWT token:

### Example Usage

```java
import io.storeyes.storeyes_coffee.security.KeycloakTokenUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
public class UserController {
    
    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getProfile() {
        String userId = KeycloakTokenUtils.getUserId();
        String email = KeycloakTokenUtils.getEmail();
        String username = KeycloakTokenUtils.getPreferredUsername();
        String fullName = KeycloakTokenUtils.getFullName();
        
        Map<String, Object> profile = Map.of(
            "userId", userId,
            "email", email,
            "username", username,
            "fullName", fullName != null ? fullName : ""
        );
        
        return ResponseEntity.ok(profile);
    }
    
    @GetMapping("/roles")
    public ResponseEntity<Map<String, Object>> getRoles() {
        boolean isAdmin = KeycloakTokenUtils.hasRealmRole("admin");
        boolean hasClientRole = KeycloakTokenUtils.hasClientRole("storeyes-mobile", "user");
        
        return ResponseEntity.ok(Map.of(
            "isAdmin", isAdmin,
            "hasClientRole", hasClientRole
        ));
    }
}
```

### Available Utility Methods

- `getUserId()` - Get the user's unique identifier (subject)
- `getEmail()` - Get the user's email address
- `getPreferredUsername()` - Get the preferred username
- `getGivenName()` - Get first name
- `getFamilyName()` - Get last name
- `getFullName()` - Get full name (given_name + family_name)
- `getRealmAccess()` - Get realm roles as a Map
- `getResourceAccess()` - Get client-specific roles as a Map
- `getClaim(String claimName, Class<T> clazz)` - Get a custom claim
- `getAllClaims()` - Get all claims as a Map
- `hasRealmRole(String role)` - Check if user has a realm role
- `hasClientRole(String clientId, String role)` - Check if user has a client role

## Token Claims

When a token is validated, it contains these standard Keycloak claims:

- `sub`: User ID (unique identifier)
- `email`: User's email address
- `preferred_username`: Username
- `given_name`: First name (if set)
- `family_name`: Last name (if set)
- `realm_access`: Realm roles (`{"roles": ["role1", "role2"]}`)
- `resource_access`: Client-specific roles (`{"client-id": {"roles": ["role1"]}}`)
- `exp`: Token expiration timestamp
- `iat`: Token issued at timestamp
- `iss`: Token issuer (realm URI)
- `aud`: Token audience (client ID)

## Role-Based Access Control

Roles are automatically extracted from the JWT token and converted to Spring Security authorities with the `ROLE_` prefix.

You can use method-level security annotations:

```java
import org.springframework.security.access.prepost.PreAuthorize;

@PreAuthorize("hasRole('ADMIN')")
@GetMapping("/admin-only")
public ResponseEntity<String> adminEndpoint() {
    return ResponseEntity.ok("Admin access granted");
}

@PreAuthorize("hasAnyRole('USER', 'ADMIN')")
@GetMapping("/user-or-admin")
public ResponseEntity<String> userOrAdminEndpoint() {
    return ResponseEntity.ok("Access granted");
}
```

## Error Responses

### 401 Unauthorized

Returned when:
- No token is provided
- Token is invalid or expired
- Token signature verification fails

Response format:
```json
{
  "error": "Unauthorized",
  "message": "Authentication required"
}
```

### 403 Forbidden

Returned when:
- User doesn't have required permissions/roles

Response format:
```json
{
  "error": "Forbidden",
  "message": "Access denied"
}
```

## Testing with Postman/cURL

### Example Request

```bash
curl -X GET https://api.storeyes.io/api/alerts \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json"
```

Replace `<your-jwt-token>` with a valid JWT token obtained from Keycloak.

### Obtaining a Token

You can obtain a token from Keycloak using:

```bash
curl -X POST http://15.216.37.183/realms/storeyes/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=storeyes-mobile" \
  -d "username=your-username" \
  -d "password=your-password"
```

**Note**: This is only for testing. In production, tokens should be obtained through the mobile app's authentication flow.

## Environment Variables

You can override Keycloak configuration using environment variables:

- `KEYCLOAK_ISSUER_URI`: Override the issuer URI
- `KEYCLOAK_AUDIENCE`: Override the expected audience

Example:
```bash
export KEYCLOAK_ISSUER_URI=http://localhost:8080/realms/storeyes
export KEYCLOAK_AUDIENCE=storeyes-mobile
```

