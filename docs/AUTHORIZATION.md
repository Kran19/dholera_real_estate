# AUTHORIZATION & ROLE-BASED ACCESS CONTROL (RBAC) — DHOLERA REAL ESTATE

---

## 1. Role Definitions

1. **`super_admin`**: Administrator account with full operational, administrative, user management, and property management privileges.
2. **`user`**: Standard client account with read-only access to browse, search, and filter property listings.

---

## 2. Permission Matrix

| Resource / Endpoint | Method | Public | User (`user`) | Super Admin (`super_admin`) |
| :--- | :--- | :--- | :--- | :--- |
| `/api/auth/login.php` | `POST` | YES | YES | YES |
| `/api/auth/logout.php` | `POST` | NO | YES | YES |
| `/api/properties/list.php` | `GET` | NO | YES (Read Only) | YES (Full) |
| `/api/properties/details.php` | `GET` | NO | YES (Read Only) | YES (Full) |
| `/api/properties/create.php` | `POST` | NO | ❌ FORBIDDEN (403) | YES |
| `/api/properties/update.php` | `POST` | NO | ❌ FORBIDDEN (403) | YES |
| `/api/properties/delete.php` | `POST` | NO | ❌ FORBIDDEN (403) | YES |
| `/api/users/list.php` | `GET` | NO | ❌ FORBIDDEN (403) | YES |
| `/api/users/create.php` | `POST` | NO | ❌ FORBIDDEN (403) | YES |
| `/api/users/update.php` | `POST` | NO | ❌ FORBIDDEN (403) | YES |
| `/api/users/status.php` | `POST` | NO | ❌ FORBIDDEN (403) | YES |
| `/api/users/delete.php` | `POST` | NO | ❌ FORBIDDEN (403) | YES |

---

## 3. Backend Middleware Security Enforcement

Authorization checks are performed in Core PHP **BEFORE** any database modification or data retrieval occurs:

```php
// Example middleware usage in admin-only endpoints:
require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

// middleware/auth.php executes first:
// Validates Bearer Token -> sets $currentUser

// middleware/admin.php executes second:
if ($currentUser['role'] !== 'super_admin') {
    sendJsonResponse(false, 'Forbidden: Super Admin access required', null, 403);
    exit();
}
```

---

## 4. Frontend (Flutter) UI Enforcement vs. Backend Security

- **Flutter UI Control:** Hides administrative buttons (e.g. "Add Property", "Edit User", "Delete") for normal users to provide a clean UX.
- **Backend Mandate:** Hiding buttons in Flutter is **NOT** a security boundary. The PHP backend enforces independent validation. If a user attempts to call `/api/properties/create.php` directly with a normal user token, the server returns HTTP 403 Forbidden.
