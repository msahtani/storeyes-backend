# Authentication Proxy API Reference

## Base URL

```
https://api.storeyes.io
```

All endpoints require HTTPS.

---

## Endpoints

### POST /auth/login

Authenticate user with username and password.

**Request:**

```http
POST /auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**

```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "expiresIn": 300,
  "tokenType": "Bearer"
}
```

**Response (400 Bad Request):**

```json
{
  "error": "Validation failed",
  "message": "Username is required"
}
```

**Response (401 Unauthorized):**

```json
{
  "error": "Invalid username or password"
}
```

**Response (500 Internal Server Error):**

```json
{
  "error": "Authentication failed: <error message>"
}
```

---

### POST /auth/refresh

Refresh access token using refresh token.

**Request:**

```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ..."
}
```

**Response (200 OK):**

```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "expiresIn": 300,
  "tokenType": "Bearer"
}
```

**Response (400 Bad Request):**

```json
{
  "error": "Validation failed",
  "message": "Refresh token is required"
}
```

**Response (401 Unauthorized):**

```json
{
  "error": "Invalid or expired refresh token"
}
```

**Response (500 Internal Server Error):**

```json
{
  "error": "Token refresh failed: <error message>"
}
```

---

### POST /auth/logout

Logout user by revoking refresh token.

**Request:**

```http
POST /auth/logout
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ..."
}
```

**Response (200 OK):**

```json
{
  "message": "Logged out successfully"
}
```

**Note:** The logout endpoint will return 200 OK even if Keycloak token revocation fails (best-effort revocation). The client should clear local token storage regardless.

---

## Error Responses

All error responses follow this format:

```json
{
  "error": "Error message describing what went wrong"
}
```

### HTTP Status Codes

- `200 OK` - Request succeeded
- `400 Bad Request` - Invalid request format or validation failed
- `401 Unauthorized` - Authentication failed or token invalid
- `500 Internal Server Error` - Server error (check logs)

---

## Authentication for Protected Endpoints

After obtaining an access token from `/auth/login` or `/auth/refresh`, include it in the `Authorization` header for protected API endpoints:

```http
GET /api/alerts
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...
Content-Type: application/json
```

**Important:**

- Use the exact format: `Bearer <token>` (with space after "Bearer")
- The token must be a valid JWT issued by Keycloak
- The token must not be expired

---

## Example Usage

### cURL Examples

#### Login

```bash
curl -X POST https://api.storeyes.io/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user@example.com",
    "password": "password123"
  }'
```

#### Refresh Token

```bash
curl -X POST https://api.storeyes.io/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ..."
  }'
```

#### Logout

```bash
curl -X POST https://api.storeyes.io/auth/logout \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ..."
  }'
```

#### Protected API Call

```bash
curl -X GET https://api.storeyes.io/api/alerts \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ..." \
  -H "Content-Type: application/json"
```

---

## Security Notes

1. **HTTPS Only**: All endpoints must be accessed over HTTPS in production
2. **Password Handling**: Passwords are never logged or stored by the backend
3. **Token Storage**: Clients should store tokens securely (Keychain, SecureStore, etc.)
4. **Token Expiry**: Access tokens expire after `expiresIn` seconds (typically 300 seconds / 5 minutes)
5. **Refresh Tokens**: Use refresh tokens to obtain new access tokens before expiry
6. **Rate Limiting**: Login endpoint may be rate-limited to prevent brute force attacks

---

## Related Documentation

- [Backend Auth Proxy Architecture](./BACKEND_AUTH_PROXY_ARCHITECTURE.md) - Architecture overview
- [React Native Migration Guide](./REACT_NATIVE_AUTH_PROXY_MIGRATION.md) - Frontend migration guide
- [Keycloak Integration](./KEYCLOAK_INTEGRATION.md) - Backend Keycloak details
