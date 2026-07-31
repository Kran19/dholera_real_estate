# AUTHENTICATION SPECIFICATION — DHOLERA REAL ESTATE

---

## 1. Overview & Strategy

The Dholera Real Estate system uses a secure **HTTP Bearer Token Authentication** protocol designed for Core PHP APIs:

- **State Persistence:** Tokens are securely stored in the `user_tokens` table in MySQL.
- **Generation:** High-entropy 64-character hexadecimal tokens generated via `bin2hex(random_bytes(32))`.
- **Validation:** Every authenticated request presents the token in the standard HTTP Header:
  `Authorization: Bearer <token>`
- **Token Invalidation:** Token is deleted/invalidated from `user_tokens` upon explicit logout or expiration.
- **Flutter Storage:** On mobile, the bearer token and current user role are stored in encrypted system storage via `flutter_secure_storage`.

---

## 2. Authentication Lifecycle

```
[Flutter App]                              [Core PHP Backend]                    [MySQL DB]
      │                                             │                                 │
      │ 1. POST /api/auth/login.php                 │                                 │
      │    {username, password}                     │                                 │
      ├────────────────────────────────────────────►│                                 │
      │                                             │ 2. Query user by username       │
      │                                             ├────────────────────────────────►│
      │                                             │◄────────────────────────────────┤
      │                                             │ 3. password_verify(pass, hash)  │
      │                                             │ 4. Generate 64-char token       │
      │                                             │ 5. INSERT INTO user_tokens      │
      │                                             ├────────────────────────────────►│
      │                                             │◄────────────────────────────────┤
      │ 6. Response: {token, user_object}           │                                 │
      │◄────────────────────────────────────────────┤                                 │
      │                                             │                                 │
      │ 7. Save token in flutter_secure_storage     │                                 │
      │                                             │                                 │
      │ 8. Subsequent API Request                   │                                 │
      │    Header: Authorization: Bearer <token>    │                                 │
      ├────────────────────────────────────────────►│                                 │
      │                                             │ 9. middleware/auth.php          │
      │                                             │    Validate token & fetch user  │
      │                                             ├────────────────────────────────►│
      │                                             │◄────────────────────────────────┤
      │ 10. API Data Response                       │                                 │
      │◄────────────────────────────────────────────┤                                 │
```

---

## 3. Flutter Client Token Handling

In Flutter:
1. **App Launch (`SplashScreen`):**
   - Read token from `flutter_secure_storage`.
   - Call `/api/auth/validate_token.php` or fetch profile/properties.
   - If valid, navigate to Dashboard (Super Admin) or Property List (User).
   - If invalid/null, navigate to `LoginScreen`.
2. **Global HTTP Interceptor (`ApiClient`):**
   - Automatically attaches `Authorization: Bearer <token>` header to all outgoing non-public HTTP requests.
   - Handles `401 Unauthorized` responses by wiping local token storage and redirecting the user to `LoginScreen` with a clear message ("Session expired, please log in again").

---

## 4. Password Hashing Security Rules

- **Storage:** Passwords must **NEVER** be stored as raw text, MD5, SHA1, or base64.
- **PHP Function:** Always use PHP native `password_hash($password, PASSWORD_DEFAULT)` which uses BCRYPT / Argon2id with automatic salt generation.
- **Verification:** Always use `password_verify($password, $stored_hash)`.
