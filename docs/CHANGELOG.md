# CHANGELOG — DHOLERA REAL ESTATE

All notable changes to this project will be documented in this file.
Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.3.7] - 2026-08-06

### Fixed
- **Brochure Photo Overlay Fix**: Corrected layout mapping to show details only on page 1 (no image), circular `firstImage` on page 2, rectangular `secondImage` on page 3, and subsequent gallery images from page 4 onwards.
- **Search Caching Bypass**: Added HTTP `Cache-Control` headers globally in PHP response helpers and integrated a timestamp-based cache-buster `_t` parameter on Flutter GET requests to bypass any server/CDN caches on Hostinger.

---

## [1.3.6] - 2026-08-06

### Changed
- **A4 Landscape Brochures**: Configured all brochure pages to build in true landscape (`PdfPageFormat.a4.landscape`) to display wide maps and landscape property photos cleanly without cropping.

---

## [1.3.5] - 2026-08-06

---

## [1.3.4] - 2026-08-06

### Added
- **Horizontal Photo Reordering**: Integrated horizontal `ReorderableListView.builder` inside the property form screen, allowing admins to drag and drop images to customize the sorting sequence.
- **Custom Image Sequence Routing**: Enabled backend sequence routing (`image_sequence`) on create and update APIs to dynamically match existing IDs and newly uploaded file indices.
- **Multi-page Brochure PDF Builder**: Re-engineered the PDF generation layout:
  * Page 1 shows specifications alongside the 1st image.
  * Page 2 displays the 2nd image beside the 1st image in a circular frame.
  * Page 3 displays the 3rd image beside the 1st image in a rectangular frame.
  * Pages 4+ showcase remaining photos as full-page gallery layouts.

---

## [1.3.3] - 2026-08-06

### Added
- **Landing Price Field**: Added support for `landing_price` column in the database and property APIs.
- **Role-Based Security Bounds**: Restrict `landing_price` visibility and editing purely to Super Admins. Filtered out key from list & details API JSON responses for normal users.
- **Admin UI Details & Form**: Exposed Landing Price field in the Property Form and the Details specifications layout strictly under the admin view bounds.

---

## [1.3.2] - 2026-08-06

### Changed
- **UI Clean-up:** Removed the filter bottom-sheet and filter button next to the search bar from `PropertyListScreen` to simplify the search layout.
- **Version Bumping:** Incremented application version to `1.3.2+17` across all config files (`pubspec.yaml`, `api_config.dart`, `version.php`, `version.json`).

---

## [1.3.1] - 2026-08-06

### Changed
- **UI Layout Optimization:** Moved the "Share PDF Brochure" button from a Floating Action Button to a full-width ElevatedButton at the bottom of the property details scroll view to prevent overlapping content.
- **Version Bumping:** Incremented application version to `1.3.1+16` across all configuration files (`flutter/pubspec.yaml`, `api_config.dart`, `version.php`, `version.json`).

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
