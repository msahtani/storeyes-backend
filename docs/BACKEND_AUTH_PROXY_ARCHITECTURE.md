# Backend as Authentication Proxy Architecture

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Why This Architecture?](#why-this-architecture)
4. [Authentication Flows](#authentication-flows)
5. [Backend Responsibilities](#backend-responsibilities)
6. [API Endpoints](#api-endpoints)
7. [Security Considerations](#security-considerations)
8. [Tradeoffs](#tradeoffs)
9. [Comparison with Direct Keycloak Access](#comparison-with-direct-keycloak-access)

---

## Overview

This document describes the **Backend-as-Authentication-Proxy** architecture, where the backend API acts as a secure intermediary between the React Native mobile app and Keycloak. This architecture solves the Android network security policy issue that blocks HTTP connections from mobile apps.

### Key Principles

- ✅ Mobile app **never** communicates directly with Keycloak
- ✅ Backend securely intermediates all authentication flows
- ✅ All communication between mobile app and backend uses **HTTPS**
- ✅ Backend can communicate with Keycloak over **HTTP or HTTPS**
- ✅ Solution is Play Store compliant and production-ready

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     React Native App                         │
│                    (Android / iOS)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTPS Only
                         │ (Port 8443)
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  Backend API (Spring Boot)                   │
│                    Authentication Proxy                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  /auth/login  →  Keycloak Token Endpoint            │  │
│  │  /auth/refresh →  Keycloak Token Endpoint            │  │
│  │  /auth/logout  →  Keycloak Logout Endpoint           │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  JWT Token Validation (OAuth2 Resource Server)       │  │
│  │  /api/** → Protected endpoints                       │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTP / HTTPS
                         │ (Keycloak Server)
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Keycloak Server                           │
│              (http://15.216.37.183/realms/storeyes)         │
│                                                              │
│  • Token Issuance                                            │
│  • User Authentication                                       │
│  • Token Refresh                                             │
│  • Token Revocation                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Why This Architecture?

### Problem Statement

**Android Network Security Policy** blocks HTTP connections by default (Android 9+). When a React Native app tries to communicate directly with Keycloak over HTTP, it fails with network errors:

```
Error: Network request failed
java.io.IOException: Cleartext HTTP traffic not permitted
```

### Solution

The backend acts as a proxy:

- Mobile app → Backend: **HTTPS** (always encrypted, Play Store compliant)
- Backend → Keycloak: **HTTP or HTTPS** (backend-to-backend, not exposed to mobile)

### Benefits

1. ✅ **Solves Android HTTP blocking** - Mobile app only uses HTTPS
2. ✅ **Play Store compliant** - No cleartext traffic from mobile app
3. ✅ **Single entry point** - All API calls go through backend
4. ✅ **Backend control** - Can add rate limiting, logging, security controls
5. ✅ **Keycloak isolation** - Keycloak doesn't need to be exposed to internet
6. ✅ **Flexible** - Backend can switch Keycloak URLs/realms without mobile app changes

---

## Authentication Flows

### 1️⃣ Login Flow

**Sequence Diagram:**

```
Mobile App          Backend API          Keycloak Server
    │                    │                     │
    │  POST /auth/login  │                     │
    │  {username, pass}  │                     │
    │───────────────────>│                     │
    │                    │                     │
    │                    │  POST /token        │
    │                    │  grant_type=password│
    │                    │  client_id=...      │
    │                    │  username=...       │
    │                    │  password=...       │
    │                    │────────────────────>│
    │                    │                     │
    │                    │  {access_token,     │
    │                    │   refresh_token,    │
    │                    │   expires_in}       │
    │                    │<────────────────────│
    │                    │                     │
    │  {accessToken,     │                     │
    │   refreshToken,    │                     │
    │   expiresIn}       │                     │
    │<───────────────────│                     │
    │                    │                     │
    │  Store tokens      │                     │
    │  in secure storage │                     │
    │                    │                     │
```

**Implementation:**

```javascript
// Mobile App (React Native)
const response = await fetch("https://api.storeyes.io/auth/login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    username: "user@example.com",
    password: "password123",
  }),
});

const { accessToken, refreshToken, expiresIn } = await response.json();
// Store tokens securely (e.g., SecureStore, Keychain)
```

**Backend Processing:**

1. Receives username/password from mobile app
2. Validates input (non-empty, proper format)
3. Forwards credentials to Keycloak token endpoint
4. Keycloak authenticates user and returns tokens
5. Backend returns tokens to mobile app (never logs password)
6. Mobile app stores tokens securely

---

### 2️⃣ Token Refresh Flow

**Sequence Diagram:**

```
Mobile App          Backend API          Keycloak Server
    │                    │                     │
    │  POST /auth/refresh│                     │
    │  {refreshToken}    │                     │
    │───────────────────>│                     │
    │                    │                     │
    │                    │  POST /token        │
    │                    │  grant_type=refresh │
    │                    │  refresh_token=...  │
    │                    │────────────────────>│
    │                    │                     │
    │                    │  {access_token,     │
    │                    │   refresh_token,    │
    │                    │   expires_in}       │
    │                    │<────────────────────│
    │                    │                     │
    │  {accessToken,     │                     │
    │   refreshToken,    │                     │
    │   expiresIn}       │                     │
    │<───────────────────│                     │
    │                    │                     │
    │  Update stored     │                     │
    │  tokens            │                     │
    │                    │                     │
```

**Implementation:**

```javascript
// Mobile App (React Native)
const response = await fetch("https://api.storeyes.io/auth/refresh", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    refreshToken: storedRefreshToken,
  }),
});

const { accessToken, refreshToken, expiresIn } = await response.json();
// Update stored tokens
```

**Backend Processing:**

1. Receives refresh token from mobile app
2. Forwards refresh token to Keycloak token endpoint
3. Keycloak validates refresh token and returns new tokens
4. Backend returns new tokens to mobile app
5. Mobile app updates stored tokens

---

### 3️⃣ Logout Flow

**Sequence Diagram:**

```
Mobile App          Backend API          Keycloak Server
    │                    │                     │
    │  POST /auth/logout │                     │
    │  {refreshToken}    │                     │
    │───────────────────>│                     │
    │                    │                     │
    │                    │  POST /logout       │
    │                    │  refresh_token=...  │
    │                    │────────────────────>│
    │                    │                     │
    │                    │  200 OK             │
    │                    │<────────────────────│
    │                    │                     │
    │  {message: "..."}  │                     │
    │<───────────────────│                     │
    │                    │                     │
    │  Clear tokens      │                     │
    │  from storage      │                     │
    │                    │                     │
```

**Implementation:**

```javascript
// Mobile App (React Native)
await fetch("https://api.storeyes.io/auth/logout", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    refreshToken: storedRefreshToken,
  }),
});

// Clear tokens from secure storage
await SecureStore.deleteItemAsync("accessToken");
await SecureStore.deleteItemAsync("refreshToken");
```

**Backend Processing:**

1. Receives refresh token from mobile app
2. Attempts to revoke refresh token in Keycloak
3. Returns success response (even if Keycloak revocation fails - tokens will expire anyway)
4. Mobile app clears local token storage

---

### 4️⃣ Authenticated API Calls

**Flow:**

```
Mobile App          Backend API          Keycloak Server
    │                    │                     │
    │  GET /api/alerts   │                     │
    │  Authorization:    │                     │
    │  Bearer <token>    │                     │
    │───────────────────>│                     │
    │                    │                     │
    │                    │  Validate JWT       │
    │                    │  (check signature,  │
    │                    │   expiry, issuer,   │
    │                    │   audience)         │
    │                    │                     │
    │                    │  (Optional: fetch   │
    │                    │   JWKS from         │
    │                    │   Keycloak)         │
    │                    │────────────────────>│
    │                    │<────────────────────│
    │                    │                     │
    │                    │  Process request    │
    │                    │  (if token valid)   │
    │                    │                     │
    │  {alerts: [...]}   │                     │
    │<───────────────────│                     │
    │                    │                     │
```

**Implementation:**

```javascript
// Mobile App (React Native)
const token = await SecureStore.getItemAsync("accessToken");

const response = await fetch("https://api.storeyes.io/api/alerts", {
  method: "GET",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
});

const alerts = await response.json();
```

**Backend Processing:**

1. Extracts JWT token from `Authorization: Bearer <token>` header
2. Validates token signature using Keycloak's public keys (JWKS)
3. Validates token claims (issuer, audience, expiry)
4. Extracts user information and roles from token
5. Processes request if token is valid
6. Returns 401 if token is invalid/expired

---

## Backend Responsibilities

### 1. Credential Handling

✅ **MUST:**

- Accept credentials over HTTPS only
- Never log passwords in production logs
- Validate input before forwarding to Keycloak
- Return appropriate error messages without exposing sensitive details

❌ **MUST NOT:**

- Store passwords in plaintext
- Log passwords to logs or audit trails
- Forward requests without validation

### 2. Token Management

✅ **MUST:**

- Forward tokens securely to Keycloak
- Return tokens to mobile app over HTTPS
- Handle token refresh errors gracefully
- Support logout token revocation

### 3. Security Controls

✅ **SHOULD:**

- Implement rate limiting on `/auth/login` endpoint
- Monitor failed login attempts
- Log authentication events (without sensitive data)
- Validate Keycloak responses before returning to client

### 4. Error Handling

✅ **MUST:**

- Map Keycloak errors to appropriate HTTP status codes
- Return clear error messages to mobile app
- Handle Keycloak unavailability gracefully
- Never expose internal Keycloak errors directly

### 5. Token Validation

✅ **MUST:**

- Validate JWT tokens for protected endpoints
- Check token signature, expiry, issuer, audience
- Extract user information from valid tokens
- Reject invalid/expired tokens with 401

---

## API Endpoints

### POST /auth/login

Authenticate user with username and password.

**Request:**

```json
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

**Response (401 Unauthorized):**

```json
{
  "error": "Invalid username or password"
}
```

**Response (500 Internal Server Error):**

```json
{
  "error": "Authentication failed: <message>"
}
```

---

### POST /auth/refresh

Refresh access token using refresh token.

**Request:**

```json
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

**Response (401 Unauthorized):**

```json
{
  "error": "Invalid or expired refresh token"
}
```

---

### POST /auth/logout

Logout user by revoking refresh token.

**Request:**

```json
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

---

## Security Considerations

### Password Handling

✅ **Backend:**

- Passwords are received over HTTPS (encrypted in transit)
- Passwords are never stored
- Passwords are forwarded to Keycloak immediately
- Passwords are never logged

✅ **Mobile App:**

- Never stores passwords
- Only sends passwords during login
- Clears password from memory after use

### Token Storage

✅ **Mobile App:**

- Use secure storage mechanisms:
  - **Android**: `androidx.security.crypto.EncryptedSharedPreferences` or KeyStore
  - **iOS**: Keychain Services
  - **React Native**: `react-native-keychain` or `expo-secure-store`
- Never store tokens in AsyncStorage (unencrypted)
- Store both access token and refresh token

### Token Rotation / Refresh

✅ **Mobile App:**

- Check token expiry before making API calls
- Automatically refresh token when expired (or close to expiry)
- Handle refresh failures by redirecting to login
- Update stored tokens after successful refresh

✅ **Backend:**

- Validate tokens before processing requests
- Return 401 for expired/invalid tokens
- Support token refresh endpoint

### Rate Limiting & Abuse Prevention

✅ **Backend SHOULD:**

- Implement rate limiting on `/auth/login`:
  - Limit per IP address (e.g., 5 attempts per minute)
  - Limit per username (e.g., 3 attempts per minute)
- Monitor failed login attempts
- Implement exponential backoff for repeated failures
- Consider temporary IP blocking for abuse

### Logging & Auditing

✅ **Backend SHOULD:**

- Log authentication events (success/failure)
- Include: username, timestamp, IP address
- **Exclude**: passwords, tokens (only log token presence)
- Monitor for suspicious patterns (brute force, etc.)

✅ **Mobile App:**

- Log authentication errors (not tokens)
- Handle network errors gracefully
- Show user-friendly error messages

---

## Tradeoffs

### ✅ Advantages

1. **Solves Android HTTP blocking** - Mobile app only uses HTTPS
2. **Play Store compliant** - No cleartext traffic from mobile
3. **Backend control** - Can add rate limiting, logging, security controls
4. **Keycloak isolation** - Keycloak doesn't need public HTTPS endpoint
5. **Single entry point** - All API calls go through backend
6. **Flexible** - Backend can change Keycloak configuration without mobile app updates

### ❌ Disadvantages

1. **Backend handles credentials** - Backend must securely handle passwords (never store/log)
2. **Additional backend responsibility** - Backend must maintain authentication proxy code
3. **Single point of failure** - If backend is down, authentication fails (but this is already the case for API calls)
4. **Latency** - Extra hop adds minimal latency (typically <50ms)
5. **Backend-to-Keycloak connection** - Backend must be able to reach Keycloak (HTTP or HTTPS)

### ⚖️ Comparison with Direct Keycloak HTTPS

| Aspect                          | Backend Proxy                | Direct Keycloak HTTPS     |
| ------------------------------- | ---------------------------- | ------------------------- |
| **Android HTTP blocking**       | ✅ Solved                    | ✅ Not applicable (HTTPS) |
| **Keycloak HTTPS required**     | ❌ No                        | ✅ Yes                    |
| **Backend credential handling** | ✅ Required                  | ❌ Not needed             |
| **Backend complexity**          | ⚠️ Medium                    | ✅ Low                    |
| **Mobile app complexity**       | ✅ Simple (just API calls)   | ⚠️ Medium (OAuth2 flows)  |
| **Rate limiting**               | ✅ Easy (backend)            | ⚠️ Keycloak configuration |
| **Token validation**            | ✅ Same (both validate JWTs) | ✅ Same                   |
| **Keycloak exposure**           | ✅ Internal only             | ⚠️ Public endpoint needed |

---

## Comparison with Direct Keycloak Access

### Direct Keycloak Access (Traditional Approach)

**Architecture:**

```
Mobile App → HTTPS → Keycloak (for auth)
Mobile App → HTTPS → Backend API (for data)
```

**Requirements:**

- Keycloak must be exposed over HTTPS
- Mobile app implements OAuth2/OpenID Connect flows
- Mobile app handles token refresh, logout, etc.

**When to use:**

- Keycloak is already exposed over HTTPS
- Mobile app teams prefer direct OAuth2 integration
- Backend wants to avoid credential handling

### Backend Proxy (This Architecture)

**Architecture:**

```
Mobile App → HTTPS → Backend API (for auth + data)
Backend API → HTTP/HTTPS → Keycloak
```

**Requirements:**

- Backend must handle authentication proxy logic
- Backend must securely handle credentials
- Mobile app uses simple REST API calls

**When to use:**

- Keycloak is only available over HTTP
- Android app cannot connect to Keycloak directly
- Backend wants centralized control over authentication
- Mobile app teams prefer simple API integration

---

## Implementation Status

✅ **Completed:**

- Backend authentication endpoints (`/auth/login`, `/auth/refresh`, `/auth/logout`)
- DTOs for requests and responses
- Security configuration (public access to `/auth/**`)
- RestTemplate configuration for Keycloak communication

📝 **Next Steps:**

1. Add rate limiting to `/auth/login` endpoint
2. Add comprehensive logging (without sensitive data)
3. Add monitoring and alerting for failed authentication attempts
4. Update React Native app to use new endpoints (see migration guide)

---

## Related Documentation

- [Frontend Migration Guide](./REACT_NATIVE_AUTH_PROXY_MIGRATION.md) - How to update React Native app
- [Keycloak Integration](./KEYCLOAK_INTEGRATION.md) - Backend Keycloak integration details
- [Security Configuration](./SECURITY_CONFIG.md) - Security settings and best practices
