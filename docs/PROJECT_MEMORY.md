# PROJECT MEMORY — DHOLERA REAL ESTATE

> **CRITICAL INSTRUCTION FOR ALL AI ASSISTANTS:**
> Read this document completely BEFORE making any architectural, database, backend, or Flutter changes. Update this document whenever key features or structural decisions are altered.

---

## 1. Project Identity

- **Project Name:** DHOLERA REAL ESTATE
- **Project Type:** Property Listing & Property Management Mobile Application
- **Primary Frontend:** Flutter Mobile Application (Cross-Platform)
- **Backend:** Core PHP REST API (Native PHP with PDO)
- **Database:** MySQL (`dholera_realestate`)
- **Current Development Environment:** Local Development on WAMP Server (MySQL @ `localhost:3306`)
- **Future Production Target:** Hostinger Shared Hosting

---

## 2. System Architecture Overview

```
Flutter Mobile App (Frontend)
       │
       ▼  HTTP / HTTPS REST API (JSON)
Core PHP API (Backend Router, Auth & RBAC Middleware)
       │
       ▼  PDO Prepared Statements
MySQL Database (dholera_realestate)
```

- **Strict Boundary:** Flutter **NEVER** connects directly to MySQL. All access is brokered through the Core PHP REST API.
- **Configurability:** Centralized configurations in both Backend (`backend/config/database.php`) and Flutter (`lib/core/config/api_config.dart`).

---

## 3. User Roles & Access Control

| Role | Permissions |
| :--- | :--- |
| **Super Admin** | Full Access: Manage users (create, edit, activate/deactivate, delete), manage properties (create, edit, delete), upload/remove property images (max 5), search & filter properties. |
| **User** | Read-Only Access: View properties list, view property details, view image galleries, search & filter properties. Cannot create/modify users or properties. |

*Role permissions are strictly verified on the Core PHP backend for every API request (`backend/middleware/admin.php`).*

---

## 4. Core Entities & Data Requirements

### Properties Schema Core Fields:
1. Village Name
2. Survey No
3. Zone
4. Town Planning (TP)
5. FP (Final Plot)
6. Road
7. Area
8. Area Unit (Initially: `Sq Yard`, `Bigha` — Extensible schema)
9. Reference
10. Landing Price (Admin-only field; filtered out securely on REST API level for normal users)
11. Property Photos (Max 5 images per property, stored on filesystem under `backend/uploads/properties/{property_id}/`)

---

## 5. Authentication & Security Summary

- **Authentication:** Token-based API Authentication (Bearer Token).
- **Password Hashing:** `password_hash(PASSWORD_DEFAULT)` & `password_verify()`.
- **Database Access:** 100% PDO prepared statements. Zero raw query concatenations.
- **File Upload Security:** Server-side MIME validation, size check (5 MB), safe random filename generation, PHP execution prevention in upload directory (`.htaccess`).

---

## 6. Current Project Status

- **Phase 0 (Foundation & Documentation):** ✅ COMPLETED
- **Phase 1 (Database & PHP Core):** ✅ COMPLETED & SEEDED
- **Phase 2 (Core PHP Auth & Token APIs):** ✅ COMPLETED
- **Phase 3 (Flutter Initialization & Auth UI):** ✅ COMPLETED
- **Phase 4 (Super Admin User Management):** ✅ COMPLETED
- **Phase 5 (Property Management CRUD):** ✅ COMPLETED
- **Phase 6 (Image Upload System):** ✅ COMPLETED (Max 5 photos, filesystem storage)
- **Phase 7 (User Property Browsing & Gallery):** ✅ COMPLETED
- **Phase 8 (Server-Side Search, Filter & Pagination):** ✅ COMPLETED
- **Phase 9 (QA & Verification):** ✅ Verified Clean Build & API Login
- **Phase 10 (Production Deployment Preparation):** ⏳ READY FOR HOSTINGER DEPLOYMENT WHEN NEEDED

---

## 7. Default Accounts (Local WAMP Environment)

| Role | Username | Passcode |
| :--- | :--- | :--- |
| **Super Admin** | `admin` | `Admin@123` |
| **Normal User** | `user1` | `User@123` |

---

## 8. AI Development Rules Summary

- Always inspect codebase before writing code.
- Always keep Flutter models, PHP API contracts, and MySQL schema synchronized.
- Never modify authentication or authorization logic without analyzing security implications.
- Document every change in `docs/CHANGELOG.md` and `docs/PROJECT_MEMORY.md`.
