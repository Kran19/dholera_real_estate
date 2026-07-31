# ARCHITECTURE DOCUMENTATION — DHOLERA REAL ESTATE

---

## 1. System Architecture

The Dholera Real Estate application is structured following a classic, decoupled 3-tier mobile/web architecture:

```
+-------------------------------------------------------------+
|                     FLUTTER MOBILE APP                      |
| (UI Layer, State Management via Provider, ApiClient Network)|
+-------------------------------------------------------------+
                              │
                              │ HTTP / HTTPS JSON REST API
                              ▼
+-------------------------------------------------------------+
|                      CORE PHP BACKEND                       |
| (API Endpoints, Middleware Auth/RBAC, PDO DB Interface,    |
|  Image Upload Service)                                      |
+-------------------------------------------------------------+
                              │
                              │ Local Socket / TCP connection (PDO)
                              ▼
+-------------------------------------------------------------+
|                        MYSQL DATABASE                       |
| (dholera_realestate: users, properties, property_images)    |
+-------------------------------------------------------------+
```

---

## 2. Architectural Boundaries & Data Flow

### A. Authentication & Request Flow
1. **User Action:** Flutter user enters credentials (Username & Passcode) on `LoginScreen`.
2. **API Request:** `ApiClient` sends `POST /api/auth/login.php` with JSON payload `{ "username": "...", "password": "..." }`.
3. **Backend Processing:**
   - PHP router accepts request.
   - Searches `users` table via PDO prepared statement by `username`.
   - Validates user status (`active`).
   - Verifies passcode using `password_verify()`.
   - Generates a secure random 64-character bearer token, inserts token into DB (or auth session table) with expiration.
   - Returns `{ "success": true, "data": { "token": "...", "user": { "id": 1, "username": "admin", "role": "super_admin" } } }`.
4. **Flutter Storage:** Flutter stores token securely using `flutter_secure_storage` and updates `AuthProvider` state.

### B. Authenticated Data Fetching Flow (e.g. Property Listing)
1. **Flutter Request:** `PropertyProvider` calls `PropertyService.fetchProperties(page: 1, limit: 20, search: '...', village: '...')`.
2. **HTTP Request:** `ApiClient` includes `Authorization: Bearer <token>` in headers.
3. **Backend Middleware Validation:**
   - `middleware/auth.php` extracts token from header.
   - Queries DB to validate token authenticity, status, and expiration.
   - Attaches authenticated `$currentUser` object to global request context.
4. **Endpoint Execution:** `api/properties/list.php` applies search, filters, pagination limit/offset, executes SQL queries with PDO.
5. **JSON Response:** Returns properties array, image URLs, and pagination metadata.
6. **Flutter Rendering:** Flutter parses response into `Property` model list and renders UI cards.

### C. Image Upload & Property Creation Flow
1. **Admin Action:** Super Admin selects property details & up to 5 images from device gallery.
2. **Multipart API Request:** `ApiClient` sends `POST /api/properties/create.php` as `multipart/form-data` with Bearer token.
3. **Backend Middleware:** Verifies token AND verifies role === `super_admin` (`middleware/admin.php`).
4. **Validation & Storage:**
   - PHP validates input fields and image files (MIME, max 5 images, file sizes <= 5MB).
   - Generates sanitized unique filenames (e.g. `img_65cf123a_1.jpg`).
   - Saves files to `backend/uploads/properties/{property_id}/`.
   - Inserts record into `properties` table.
   - Inserts records into `property_images` table with relative paths.
5. **Response:** PHP returns success JSON with created property payload.

---

## 3. Core Principles & Safeguards

1. **Zero Direct DB Access:** Flutter never communicates directly with MySQL.
2. **Stateless API:** Each API request is self-contained and verified via Bearer token.
3. **Centralized Configuration:**
   - Backend DB credentials encapsulated in `backend/config/database.php`.
   - Flutter API endpoint URLs encapsulated in `lib/core/config/api_config.dart`.
4. **Fail-Safe Authorization:** Backend independently enforces role checks for every single non-public endpoint.
