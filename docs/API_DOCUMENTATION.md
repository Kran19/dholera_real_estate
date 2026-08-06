# API DOCUMENTATION — DHOLERA REAL ESTATE

All API endpoints return standard JSON responses and HTTP status codes.

---

## 1. Standard Response Structure

### Success Response Format:
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {},
  "pagination": null
}
```

### Error Response Format:
```json
{
  "success": false,
  "message": "Detailed human-readable error description",
  "data": null,
  "errors": {
    "field_name": ["Specific validation error message"]
  }
}
```

---

## 2. Authentication Endpoints

### `POST /api/auth/login.php`
- **Auth Required:** No
- **Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "username": "admin",
  "password": "Password123!"
}
```
- **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "64_char_hexadecimal_secure_token",
    "user": {
      "id": 1,
      "username": "admin",
      "role": "super_admin",
      "status": "active"
    }
  }
}
```

### `POST /api/auth/logout.php`
- **Auth Required:** Yes (`Authorization: Bearer <token>`)
- **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully",
  "data": null
}
```

---

## 3. User Management Endpoints (Super Admin Only)

### `GET /api/users/list.php`
- **Auth Required:** Yes (Super Admin)
- **Query Parameters:** `page=1`, `limit=20`, `search=...`
- **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Users retrieved successfully",
  "data": {
    "users": [
      {
        "id": 2,
        "username": "john_doe",
        "role": "user",
        "status": "active",
        "created_at": "2026-07-31 10:00:00"
      }
    ]
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "total_pages": 1
  }
}
```

### `POST /api/users/create.php`
- **Auth Required:** Yes (Super Admin)
- **Request Body:**
```json
{
  "username": "john_doe",
  "password": "Password123!",
  "status": "active"
}
```

### `POST /api/users/update.php`
- **Auth Required:** Yes (Super Admin)
- **Request Body:**
```json
{
  "id": 2,
  "password": "NewPassword123!",
  "status": "inactive"
}
```

### `POST /api/users/delete.php`
- **Auth Required:** Yes (Super Admin)
- **Request Body:**
```json
{
  "id": 2
}
```

---

## 4. Property Endpoints

### `GET /api/properties/list.php`
- **Auth Required:** Yes (All Roles: Super Admin & User)
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 20)
  - `search` (searches `village_name`, `survey_no`, `reference`)
  - `village_name` (exact/partial filter)
  - `zone` (exact filter)
  - `area_unit` (exact filter)
- **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Properties fetched successfully",
  "data": {
    "properties": [
      {
        "id": 15,
        "village_name": "Kadipur",
        "survey_no": "102/A",
        "zone": "Residential",
        "tp": "TP-1",
        "fp": "FP-45",
        "road": "24 Mtr",
        "area": 500.00,
        "area_unit": "Sq Yard",
        "reference": "Direct Owner",
        "landing_price": "12 Lakhs",
        "primary_image": "http://10.0.2.2/dholera_real_estate/backend/uploads/properties/15/img_1.jpg",
        "images": [
          {
            "id": 101,
            "image_url": "http://10.0.2.2/dholera_real_estate/backend/uploads/properties/15/img_1.jpg",
            "sort_order": 1
          }
        ],
        "created_at": "2026-07-31 11:00:00"
      }
    ]
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "total_pages": 3
  }
}
```
*Note: The `landing_price` field is only returned if the authenticated user has the `super_admin` role.*

### `GET /api/properties/details.php?id=15`
- **Auth Required:** Yes (All Roles)
- **Returns:** Detailed property object with full array of images (up to 5).
- **Behavior:** The `landing_price` field is included in the property details object only if the user role is `super_admin`.

### `POST /api/properties/create.php`
- **Auth Required:** Yes (Super Admin Only)
- **Content-Type:** `multipart/form-data`
- **Fields:** `village_name`, `survey_no`, `zone`, `tp`, `fp`, `road`, `area`, `area_unit`, `reference`, `landing_price` (optional)
- **Files:** `images[]` (Max 5 files, image/jpeg, image/png, max 5MB per file)

### `POST /api/properties/update.php`
- **Auth Required:** Yes (Super Admin Only)
- **Fields:** `id`, updated property fields (including `landing_price`), optional new images.

### `POST /api/properties/delete.php`
- **Auth Required:** Yes (Super Admin Only)
- **Request Body:** `{ "id": 15 }`
- **Behavior:** Deletes DB records and removes associated physical image directory on server filesystem.
