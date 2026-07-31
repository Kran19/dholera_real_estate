# CHANGELOG — DHOLERA REAL ESTATE

All notable changes to this project will be documented in this file.
Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] - 2026-07-31

### Added
- **Top-Level Folder Restructuring:**
  - Restructured repository into distinct `php/` (Core PHP REST API) and `flutter/` (Flutter Mobile App) top-level directories for hostinger deployment clarity.
- **Hostinger Shared Hosting Deployment Guide:**
  - Created `docs/HOSTINGER_DEPLOYMENT.md` with step-by-step instructions for Hostinger hPanel MySQL database creation, File Manager upload (`public_html/php`), permissions setup, and production URL configuration.
- **Automated Test Suite:**
  - Created unit tests (`flutter/test/unit_test.dart`) for `UserModel`, `PropertyModel`, and `PropertyImageModel` JSON serialization.
  - Verified 100% test pass rate across all unit and widget tests.
- **Production Build:**
  - Verified clean Android Release APK compilation (`flutter build apk --release`).

---

## [0.1.0] - 2026-07-31

### Added
- **Phase 0 Documentation & Memory Foundation:**
  - Created master project index `docs/README.md`.
  - Created permanent project memory `docs/PROJECT_MEMORY.md`.
  - Created end-to-end architecture guide `docs/ARCHITECTURE.md`.
  - Created MySQL database schema specification `docs/DATABASE_SCHEMA.md`.
  - Created REST API contract documentation `docs/API_DOCUMENTATION.md`.
  - Created token authentication specification `docs/AUTHENTICATION.md`.
  - Created authorization & RBAC permission matrix `docs/AUTHORIZATION.md`.
  - Created Flutter architecture & directory structure guide `docs/FLUTTER_ARCHITECTURE.md`.
  - Created local development & emulator configuration guide `docs/LOCAL_DEVELOPMENT.md`.
  - Created image upload security & file handling specification `docs/IMAGE_UPLOADS.md`.
  - Created UI/UX design guidelines & color tokens `docs/UI_UX_GUIDELINES.md`.
  - Created OWASP-aligned security specification `docs/SECURITY.md`.
  - Created quality assurance test matrix `docs/TESTING.md`.
  - Created architectural decision record `docs/DECISIONS.md`.
  - Created known issues tracker `docs/KNOWN_ISSUES.md`.
  - Created 10-phase project roadmap `docs/ROADMAP.md`.
  - Created 15 AI development rules `docs/AI_DEVELOPMENT_RULES.md`.
  - Created root `PROJECT_STATUS.md`.
