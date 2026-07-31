# DEVELOPMENT ROADMAP — DHOLERA REAL ESTATE

---

## 📌 Development Phases Summary

```
Phase 0: Project Documentation & Architecture (Current)
   │
   ▼
Phase 1: MySQL Database Schema + Core PHP Backend Foundation
   │
   ▼
Phase 2: Core PHP Authentication & Authorization APIs
   │
   ▼
Phase 3: Flutter Application Setup & Authentication Integration
   │
   ▼
Phase 4: Super Admin User Management (PHP API + Flutter UI)
   │
   ▼
Phase 5: Property Management Core APIs & Flutter UI
   │
   ▼
Phase 6: Image Upload System (PHP File Uploads + Flutter Picker/Gallery)
   │
   ▼
Phase 7: User Property Browsing & Detailed Property Screens
   │
   ▼
Phase 8: Server-Side Search, Filter & Pagination
   │
   ▼
Phase 9: Comprehensive QA Testing & Security Audit
   │
   ▼
Phase 10: Production Preparation & Hostinger Shared Hosting Deployment Guide
```

---

## Detailed Phase Breakdown

### PHASE 0: Project Documentation & Architecture Framework
- [x] Create comprehensive `docs/` suite (18 documentation files).
- [x] Establish permanent project memory `docs/PROJECT_MEMORY.md`.
- [x] Define API contracts, database schema, and security matrix.
- [x] Submit initial analysis report & implementation plan for approval.

### PHASE 1: MySQL Schema + Core PHP Backend Foundation
- [ ] Create MySQL database `dholera_realestate` and execute schema DDL.
- [ ] Create backend directory structure (`backend/api`, `config`, `middleware`, `helpers`, `uploads`).
- [ ] Create `backend/config/database.php` PDO connection wrapper.
- [ ] Create `backend/helpers/response.php` standard JSON responder.
- [ ] Seed initial Super Admin account (`admin` / `Admin@123`).

### PHASE 2: Core PHP Authentication & Authorization
- [ ] Implement `POST /api/auth/login.php` with BCRYPT verification and token generation.
- [ ] Implement `POST /api/auth/logout.php`.
- [ ] Implement `backend/middleware/auth.php` (Bearer token validation).
- [ ] Implement `backend/middleware/admin.php` (`super_admin` role validation).

### PHASE 3: Flutter Application Setup & Auth UI
- [ ] Initialize Flutter project `dholera_real_estate`.
- [ ] Configure `pubspec.yaml` dependencies (`provider`, `http`, `flutter_secure_storage`, `image_picker`, `google_fonts`).
- [ ] Build core theme, typography (`AppColors`, `AppStyles`), and `ApiClient`.
- [ ] Build `SplashScreen`, `LoginScreen`, and `AuthProvider`.

### PHASE 4: Super Admin User Management
- [ ] Build PHP user endpoints (`list.php`, `create.php`, `update.php`, `delete.php`, `status.php`).
- [ ] Build Flutter User Management screens (`UserListScreen`, `CreateUserModal`, `UserProvider`).

### PHASE 5: Property Management (Core CRUD)
- [ ] Build PHP property endpoints (`list.php`, `create.php`, `details.php`, `update.php`, `delete.php`).
- [ ] Build Flutter Property screens (`PropertyListScreen`, `AddPropertyScreen`, `PropertyDetailsScreen`).

### PHASE 6: Image Upload System
- [ ] Build PHP image upload helper & `property_images` DB synchronization (max 5 images per property).
- [ ] Build Flutter image picker UI, gallery viewer, and multipart upload service.

### PHASE 7: User Property Browsing
- [ ] Ensure non-admin `user` role receives read-only UI experience.
- [ ] Build Property detail screen with interactive full-screen photo gallery.

### PHASE 8: Server-Side Search, Filters & Pagination
- [ ] Implement backend server-side search (`village_name`, `survey_no`, `reference`) and filters (`zone`, `area_unit`).
- [ ] Implement lazy loading / infinite scroll pagination in Flutter `PropertyListScreen`.

### PHASE 9: Security Audit & Testing
- [ ] Execute test matrix (`docs/TESTING.md`).
- [ ] Security checks: SQLi, path traversal, upload security, OWASP top 10.

### PHASE 10: Production Readiness & Deployment Guide
- [ ] Prepare `docs/PRODUCTION_DEPLOYMENT.md` for Hostinger shared hosting.
- [ ] Sanitize local credentials and build production Flutter APK/App Bundle.
