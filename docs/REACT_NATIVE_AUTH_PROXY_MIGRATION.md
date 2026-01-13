# React Native Migration Guide: Backend Auth Proxy

This guide explains how to migrate your React Native app from direct Keycloak authentication to using the backend authentication proxy.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Migration Steps](#migration-steps)
3. [Code Changes](#code-changes)
4. [Before vs After](#before-vs-after)
5. [Complete Example](#complete-example)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### What Changes

**Before:**

- Mobile app calls Keycloak directly: `http://15.216.37.183/realms/storeyes/protocol/openid-connect/token`
- App handles OAuth2 password grant flow
- Android blocks HTTP connections → ❌ Network errors

**After:**

- Mobile app calls backend API: `https://api.storeyes.io/auth/login`
- App uses simple REST API calls
- All traffic is HTTPS → ✅ Works on Android

### What Stays the Same

- Token storage mechanism (still use SecureStore/Keychain)
- Token refresh logic (same concept, different endpoint)
- API calls to backend (still use `Authorization: Bearer <token>`)
- Token validation (backend still validates Keycloak JWTs)

---

## Migration Steps

### Step 1: Update Authentication Service

Replace Keycloak direct calls with backend API calls.

### Step 2: Update API Base URL

Ensure API base URL points to backend HTTPS endpoint.

### Step 3: Remove Keycloak SDK (if used)

If you're using a Keycloak SDK, remove it. We only need standard HTTP calls.

### Step 4: Update Token Storage

Keep using secure storage (no changes needed).

### Step 5: Test Authentication Flows

Test login, refresh, logout, and protected API calls.

---

## Code Changes

### 1. Authentication Service (`AuthService.js`)

#### Before (Direct Keycloak)

```javascript
// ❌ OLD: Direct Keycloak call
const KEYCLOAK_URL = "http://15.216.37.183/realms/storeyes";
const CLIENT_ID = "storeyes-mobile";

async signIn(username, password) {
  const response = await axios.post(
    `${KEYCLOAK_URL}/protocol/openid-connect/token`,
    new URLSearchParams({
      grant_type: "password",
      client_id: CLIENT_ID,
      username: username,
      password: password,
    }),
    {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    }
  );

  const { access_token, refresh_token, expires_in } = response.data;
  await this.storeTokens(access_token, refresh_token, expires_in);
  return { success: true, accessToken: access_token, refreshToken: refresh_token };
}
```

#### After (Backend Proxy)

```javascript
// ✅ NEW: Backend proxy call
const API_BASE_URL = "https://api.storeyes.io";

async signIn(username, password) {
  const response = await axios.post(
    `${API_BASE_URL}/auth/login`,
    {
      username: username,
      password: password,
    },
    {
      headers: {
        "Content-Type": "application/json",
      },
    }
  );

  const { accessToken, refreshToken, expiresIn } = response.data;
  await this.storeTokens(accessToken, refreshToken, expiresIn);
  return { success: true, accessToken, refreshToken };
}
```

---

### 2. Complete Updated AuthService

```javascript
// services/AuthService.js
import axios from "axios";
import * as SecureStore from "expo-secure-store";
// or: import AsyncStorage from "@react-native-async-storage/async-storage";

const API_BASE_URL = "https://api.storeyes.io"; // Your backend HTTPS URL
const TOKEN_STORAGE_KEY = "@storeyes:access_token";
const REFRESH_TOKEN_STORAGE_KEY = "@storeyes:refresh_token";
const TOKEN_EXPIRY_KEY = "@storeyes:token_expiry";

class AuthService {
  /**
   * Sign in with username/email and password
   * @param {string} username - User username or email address (Keycloak supports both)
   * @param {string} password - User password
   * @returns {Promise<Object>} Authentication result
   */
  async signIn(username, password) {
    try {
      const response = await axios.post(
        `${API_BASE_URL}/auth/login`,
        {
          username: username,
          password: password,
        },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      const { accessToken, refreshToken, expiresIn } = response.data;

      // Store tokens securely
      await this.storeTokens(accessToken, refreshToken, expiresIn);

      return {
        success: true,
        accessToken,
        refreshToken,
      };
    } catch (error) {
      console.error("Sign in error:", error.response?.data || error.message);

      // Handle specific error cases
      if (error.response?.status === 401) {
        return {
          success: false,
          error: "Invalid username or password",
        };
      }

      return {
        success: false,
        error: error.response?.data?.error || "Authentication failed",
      };
    }
  }

  /**
   * Store tokens securely
   * @param {string} accessToken - Access token
   * @param {string} refreshToken - Refresh token
   * @param {number} expiresIn - Expiration time in seconds
   */
  async storeTokens(accessToken, refreshToken, expiresIn) {
    const expiryTime = Date.now() + expiresIn * 1000; // Convert to milliseconds

    // Use SecureStore (recommended) or Keychain for secure storage
    await SecureStore.setItemAsync(TOKEN_STORAGE_KEY, accessToken);
    await SecureStore.setItemAsync(REFRESH_TOKEN_STORAGE_KEY, refreshToken);
    await SecureStore.setItemAsync(TOKEN_EXPIRY_KEY, expiryTime.toString());

    // Alternative: Use AsyncStorage (less secure, but works for development)
    // await AsyncStorage.multiSet([
    //   [TOKEN_STORAGE_KEY, accessToken],
    //   [REFRESH_TOKEN_STORAGE_KEY, refreshToken],
    //   [TOKEN_EXPIRY_KEY, expiryTime.toString()],
    // ]);
  }

  /**
   * Get stored access token
   * @returns {Promise<string|null>} Access token or null
   */
  async getAccessToken() {
    try {
      const token = await SecureStore.getItemAsync(TOKEN_STORAGE_KEY);
      return token;
    } catch (error) {
      console.error("Error getting token:", error);
      return null;
    }
  }

  /**
   * Get stored refresh token
   * @returns {Promise<string|null>} Refresh token or null
   */
  async getRefreshToken() {
    try {
      const token = await SecureStore.getItemAsync(REFRESH_TOKEN_STORAGE_KEY);
      return token;
    } catch (error) {
      console.error("Error getting refresh token:", error);
      return null;
    }
  }

  /**
   * Check if token is expired
   * @returns {Promise<boolean>} True if token is expired or missing
   */
  async isTokenExpired() {
    try {
      const expiryTime = await SecureStore.getItemAsync(TOKEN_EXPIRY_KEY);
      if (!expiryTime) return true;

      return Date.now() >= parseInt(expiryTime, 10);
    } catch (error) {
      return true;
    }
  }

  /**
   * Refresh access token using refresh token
   * @returns {Promise<Object>} New token response
   */
  async refreshAccessToken() {
    try {
      const refreshToken = await this.getRefreshToken();
      if (!refreshToken) {
        throw new Error("No refresh token available");
      }

      const response = await axios.post(
        `${API_BASE_URL}/auth/refresh`,
        {
          refreshToken: refreshToken,
        },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      const {
        accessToken,
        refreshToken: newRefreshToken,
        expiresIn,
      } = response.data;
      await this.storeTokens(accessToken, newRefreshToken, expiresIn);

      return {
        success: true,
        accessToken,
        refreshToken: newRefreshToken,
      };
    } catch (error) {
      console.error(
        "Token refresh error:",
        error.response?.data || error.message
      );

      // If refresh fails, user needs to sign in again
      await this.signOut();

      return {
        success: false,
        error: "Token refresh failed. Please sign in again.",
      };
    }
  }

  /**
   * Sign out and clear stored tokens
   */
  async signOut() {
    try {
      const refreshToken = await this.getRefreshToken();

      // Try to revoke token on backend (best effort)
      if (refreshToken) {
        try {
          await axios.post(
            `${API_BASE_URL}/auth/logout`,
            { refreshToken },
            {
              headers: {
                "Content-Type": "application/json",
              },
            }
          );
        } catch (error) {
          // Logout endpoint failure is not critical
          console.warn("Logout request failed:", error);
        }
      }

      // Clear local tokens
      await SecureStore.deleteItemAsync(TOKEN_STORAGE_KEY);
      await SecureStore.deleteItemAsync(REFRESH_TOKEN_STORAGE_KEY);
      await SecureStore.deleteItemAsync(TOKEN_EXPIRY_KEY);
    } catch (error) {
      console.error("Sign out error:", error);
    }
  }

  /**
   * Get current authenticated user info (decode token)
   * @returns {Promise<Object|null>} User info or null
   * @deprecated Use getUserInfo() instead to get data from backend API
   */
  async getCurrentUser() {
    try {
      const token = await this.getAccessToken();
      if (!token) return null;

      // Decode JWT token (simple base64 decode, no signature verification needed on client)
      const payload = JSON.parse(atob(token.split(".")[1]));

      return {
        id: payload.sub,
        username: payload.preferred_username,
        email: payload.email,
        name: payload.name,
        givenName: payload.given_name,
        familyName: payload.family_name,
      };
    } catch (error) {
      console.error("Error getting user info:", error);
      return null;
    }
  }

  /**
   * Get current authenticated user info from backend API
   * Recommended: Gets user data from database if available, otherwise from JWT token
   * @returns {Promise<Object|null>} User info or null
   */
  async getUserInfo() {
    try {
      const token = await this.getAccessToken();
      if (!token) return null;

      const response = await axios.get(`${API_BASE_URL}/auth/me`, {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      });

      return response.data;
    } catch (error) {
      if (error.response?.status === 401) {
        // Token expired or invalid
        console.warn("User info request failed: Unauthorized");
        return null;
      }
      console.error("Error getting user info from API:", error);
      return null;
    }
  }
}

export default new AuthService();
```

---

### 3. API Client (No Changes Needed)

The API client remains the same - it still uses `Authorization: Bearer <token>` header:

```javascript
// services/ApiClient.js
import axios from "axios";
import AuthService from "./AuthService";

const API_BASE_URL = "https://api.storeyes.io";

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// Request interceptor - Add auth token to requests
apiClient.interceptors.request.use(
  async (config) => {
    // Check if token is expired and refresh if needed
    const isExpired = await AuthService.isTokenExpired();
    let accessToken = await AuthService.getAccessToken();

    if (isExpired && accessToken) {
      // Try to refresh token
      const refreshResult = await AuthService.refreshAccessToken();
      if (refreshResult.success) {
        accessToken = refreshResult.accessToken;
      }
    }

    // Add Authorization header if token exists
    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`;
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - Handle 401 errors
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // If 401 and haven't retried yet
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        // Try to refresh token
        const refreshResult = await AuthService.refreshAccessToken();

        if (refreshResult.success) {
          // Retry original request with new token
          originalRequest.headers.Authorization = `Bearer ${refreshResult.accessToken}`;
          return apiClient(originalRequest);
        } else {
          // Refresh failed, redirect to login
          await AuthService.signOut();
          // You can navigate to login screen here
          // NavigationService.navigate('Login');
        }
      } catch (refreshError) {
        await AuthService.signOut();
        // NavigationService.navigate('Login');
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default apiClient;
```

---

### 4. Login Screen (Minimal Changes)

The login screen implementation remains largely the same:

```javascript
// screens/LoginScreen.js
import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ActivityIndicator,
} from "react-native";
import AuthService from "../services/AuthService";

const LoginScreen = ({ navigation }) => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSignIn = async () => {
    if (!username.trim() || !password.trim()) {
      Alert.alert("Error", "Please enter both username and password");
      return;
    }

    setLoading(true);

    try {
      const result = await AuthService.signIn(username.trim(), password);

      if (result.success) {
        // Get user info
        const user = await AuthService.getCurrentUser();

        // Navigate to main app
        navigation.replace("Home");
      } else {
        Alert.alert("Sign In Failed", result.error || "Invalid credentials");
      }
    } catch (error) {
      Alert.alert("Error", "An unexpected error occurred. Please try again.");
      console.error("Sign in error:", error);
    } finally {
      setLoading(false);
    }
  };

  // ... rest of the component (UI code unchanged)
};

export default LoginScreen;
```

---

## Before vs After

### Summary of Changes

| Aspect                 | Before (Direct Keycloak)                                             | After (Backend Proxy)                  |
| ---------------------- | -------------------------------------------------------------------- | -------------------------------------- |
| **Login URL**          | `http://15.216.37.183/realms/storeyes/protocol/openid-connect/token` | `https://api.storeyes.io/auth/login`   |
| **Request Format**     | `application/x-www-form-urlencoded`                                  | `application/json`                     |
| **Request Body**       | `grant_type=password&client_id=...&username=...&password=...`        | `{username: "...", password: "..."}`   |
| **Response Keys**      | `access_token`, `refresh_token`                                      | `accessToken`, `refreshToken`          |
| **Refresh URL**        | Keycloak token endpoint                                              | `https://api.storeyes.io/auth/refresh` |
| **Logout URL**         | Keycloak logout endpoint                                             | `https://api.storeyes.io/auth/logout`  |
| **Android HTTP Issue** | ❌ Blocked                                                           | ✅ Solved (HTTPS only)                 |
| **Token Storage**      | ✅ Same (SecureStore/Keychain)                                       | ✅ Same                                |
| **API Calls**          | ✅ Same (`Authorization: Bearer`)                                    | ✅ Same                                |

---

## Complete Example

Here's a complete, production-ready authentication service:

```javascript
// services/AuthService.js
import axios from "axios";
import * as SecureStore from "expo-secure-store";

const API_BASE_URL = process.env.API_BASE_URL || "https://api.storeyes.io";

const STORAGE_KEYS = {
  ACCESS_TOKEN: "@storeyes:access_token",
  REFRESH_TOKEN: "@storeyes:refresh_token",
  TOKEN_EXPIRY: "@storeyes:token_expiry",
};

class AuthService {
  async signIn(username, password) {
    try {
      const response = await axios.post(
        `${API_BASE_URL}/auth/login`,
        { username, password },
        { headers: { "Content-Type": "application/json" } }
      );

      const { accessToken, refreshToken, expiresIn } = response.data;
      await this.storeTokens(accessToken, refreshToken, expiresIn);

      return { success: true, accessToken, refreshToken };
    } catch (error) {
      const message = error.response?.data?.error || "Authentication failed";
      return { success: false, error: message };
    }
  }

  async refreshAccessToken() {
    try {
      const refreshToken = await SecureStore.getItemAsync(
        STORAGE_KEYS.REFRESH_TOKEN
      );
      if (!refreshToken) throw new Error("No refresh token");

      const response = await axios.post(
        `${API_BASE_URL}/auth/refresh`,
        { refreshToken },
        { headers: { "Content-Type": "application/json" } }
      );

      const {
        accessToken,
        refreshToken: newRefreshToken,
        expiresIn,
      } = response.data;
      await this.storeTokens(accessToken, newRefreshToken, expiresIn);

      return { success: true, accessToken, refreshToken: newRefreshToken };
    } catch (error) {
      await this.signOut();
      return { success: false, error: "Token refresh failed" };
    }
  }

  async signOut() {
    try {
      const refreshToken = await SecureStore.getItemAsync(
        STORAGE_KEYS.REFRESH_TOKEN
      );
      if (refreshToken) {
        await axios
          .post(
            `${API_BASE_URL}/auth/logout`,
            { refreshToken },
            { headers: { "Content-Type": "application/json" } }
          )
          .catch(() => {}); // Ignore errors
      }
    } finally {
      await Promise.all([
        SecureStore.deleteItemAsync(STORAGE_KEYS.ACCESS_TOKEN),
        SecureStore.deleteItemAsync(STORAGE_KEYS.REFRESH_TOKEN),
        SecureStore.deleteItemAsync(STORAGE_KEYS.TOKEN_EXPIRY),
      ]);
    }
  }

  async storeTokens(accessToken, refreshToken, expiresIn) {
    const expiryTime = Date.now() + expiresIn * 1000;
    await Promise.all([
      SecureStore.setItemAsync(STORAGE_KEYS.ACCESS_TOKEN, accessToken),
      SecureStore.setItemAsync(STORAGE_KEYS.REFRESH_TOKEN, refreshToken),
      SecureStore.setItemAsync(
        STORAGE_KEYS.TOKEN_EXPIRY,
        expiryTime.toString()
      ),
    ]);
  }

  async getAccessToken() {
    return await SecureStore.getItemAsync(STORAGE_KEYS.ACCESS_TOKEN);
  }

  async isTokenExpired() {
    const expiryTime = await SecureStore.getItemAsync(
      STORAGE_KEYS.TOKEN_EXPIRY
    );
    return !expiryTime || Date.now() >= parseInt(expiryTime, 10);
  }

  async getCurrentUser() {
    const token = await this.getAccessToken();
    if (!token) return null;

    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      return {
        id: payload.sub,
        username: payload.preferred_username,
        email: payload.email,
        name: payload.name,
      };
    } catch {
      return null;
    }
  }

  /**
   * Get current user info from backend API (recommended)
   * Gets user data from database if available, otherwise from JWT token
   */
  async getUserInfo() {
    try {
      const token = await this.getAccessToken();
      if (!token) return null;

      const response = await axios.get(`${API_BASE_URL}/auth/me`, {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      });

      return response.data;
    } catch (error) {
      if (error.response?.status === 401) {
        return null;
      }
      console.error("Error getting user info:", error);
      return null;
    }
  }
}

export default new AuthService();
```

---

## Testing

### 1. Test Login

```javascript
// Test login
const result = await AuthService.signIn("user@example.com", "password123");
console.log("Login result:", result);
// Expected: { success: true, accessToken: "...", refreshToken: "..." }
```

### 2. Test Token Refresh

```javascript
// Test refresh
const result = await AuthService.refreshAccessToken();
console.log("Refresh result:", result);
// Expected: { success: true, accessToken: "...", refreshToken: "..." }
```

### 3. Test Logout

```javascript
// Test logout
await AuthService.signOut();
const token = await AuthService.getAccessToken();
console.log("Token after logout:", token);
// Expected: null
```

### 4. Test Get User Info

```javascript
// Test getting user info from API (recommended)
const userInfo = await AuthService.getUserInfo();
console.log("User info:", userInfo);
// Expected: { id: "...", email: "...", firstName: "...", lastName: "...", preferredUsername: "..." }

// Alternative: Get user info by decoding token (deprecated)
const user = await AuthService.getCurrentUser();
console.log("User (from token):", user);
```

### 5. Test Protected API Call

```javascript
// Test API call with token
import apiClient from "./services/ApiClient";

const alerts = await apiClient.get("/api/alerts");
console.log("Alerts:", alerts.data);
// Expected: Array of alerts
```

---

## User Profile Screen Example

Here's how to use the `/auth/me` endpoint in a profile screen:

```javascript
// screens/ProfileScreen.js
import React, { useState, useEffect } from "react";
import { View, Text, StyleSheet, ActivityIndicator, Alert } from "react-native";
import AuthService from "../services/AuthService";

const ProfileScreen = () => {
  const [userInfo, setUserInfo] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadUserInfo();
  }, []);

  const loadUserInfo = async () => {
    try {
      setLoading(true);
      const user = await AuthService.getUserInfo();
      if (user) {
        setUserInfo(user);
      } else {
        Alert.alert("Error", "Failed to load user information");
      }
    } catch (error) {
      console.error("Error loading user info:", error);
      Alert.alert("Error", "Failed to load user information");
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (!userInfo) {
    return (
      <View style={styles.container}>
        <Text>No user information available</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Profile</Text>
      <View style={styles.infoContainer}>
        <Text style={styles.label}>Email:</Text>
        <Text style={styles.value}>{userInfo.email}</Text>
      </View>
      <View style={styles.infoContainer}>
        <Text style={styles.label}>First Name:</Text>
        <Text style={styles.value}>{userInfo.firstName || "N/A"}</Text>
      </View>
      <View style={styles.infoContainer}>
        <Text style={styles.label}>Last Name:</Text>
        <Text style={styles.value}>{userInfo.lastName || "N/A"}</Text>
      </View>
      <View style={styles.infoContainer}>
        <Text style={styles.label}>Username:</Text>
        <Text style={styles.value}>{userInfo.preferredUsername || "N/A"}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: "#fff",
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    marginBottom: 20,
  },
  infoContainer: {
    marginBottom: 15,
  },
  label: {
    fontSize: 14,
    color: "#666",
    marginBottom: 5,
  },
  value: {
    fontSize: 16,
    color: "#000",
  },
});

export default ProfileScreen;
```

**Key Points:**

- Use `AuthService.getUserInfo()` to fetch user data from the backend API
- The endpoint requires authentication (JWT token)
- User data is retrieved from the database if available, otherwise from JWT token claims
- Handle 401 errors (token expired) by redirecting to login
- The response includes: `id`, `email`, `firstName`, `lastName`, `preferredUsername`

---

## Troubleshooting

### Issue: "Network request failed" on Android

**Solution:** Ensure you're using HTTPS URLs, not HTTP. The backend proxy uses HTTPS.

```javascript
// ✅ Correct
const API_BASE_URL = "https://api.storeyes.io";

// ❌ Wrong
const API_BASE_URL = "http://api.storeyes.io";
```

### Issue: "Invalid username or password" but credentials are correct

**Possible causes:**

1. Backend is not running or unreachable
2. Keycloak is not accessible from backend
3. Username/password encoding issue

**Solution:** Check backend logs and ensure Keycloak is reachable from backend.

### Issue: Token refresh fails

**Possible causes:**

1. Refresh token expired
2. Backend refresh endpoint error
3. Token storage corrupted

**Solution:** Clear tokens and re-login.

### Issue: 401 Unauthorized on API calls

**Possible causes:**

1. Token expired and refresh failed
2. Token not included in request
3. Token format incorrect

**Solution:** Check that `Authorization: Bearer <token>` header is included.

---

## Checklist

- [ ] Update `AuthService.js` to use backend endpoints
- [ ] Update API base URL to HTTPS
- [ ] Remove direct Keycloak SDK (if used)
- [ ] Update login endpoint: `/auth/login`
- [ ] Update refresh endpoint: `/auth/refresh`
- [ ] Update logout endpoint: `/auth/logout`
- [ ] Test login flow
- [ ] Test token refresh flow
- [ ] Test logout flow
- [ ] Test protected API calls
- [ ] Verify tokens are stored securely
- [ ] Test on Android device (not just emulator)
- [ ] Test on iOS device
- [ ] Verify no HTTP URLs are used

---

## Next Steps

1. Deploy backend with authentication proxy endpoints
2. Update mobile app to use new endpoints
3. Test thoroughly on both Android and iOS
4. Monitor backend logs for authentication issues
5. Consider adding rate limiting if not already implemented

---

## Related Documentation

- [Backend Auth Proxy Architecture](./BACKEND_AUTH_PROXY_ARCHITECTURE.md) - Architecture overview
- [Keycloak Integration](./KEYCLOAK_INTEGRATION.md) - Backend Keycloak details
- [React Native Quick Start](./REACT_NATIVE_QUICK_START.md) - Quick setup guide
