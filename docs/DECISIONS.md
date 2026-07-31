# ARCHITECTURAL DECISION RECORDS (ADR) — DHOLERA REAL ESTATE

---

## ADR 001: Technology Stack Selection

- **Date:** 2026-07-31
- **Status:** Approved
- **Context:** Need a fast, maintainable, mobile property listing app that can run locally during development and be hosted easily on Hostinger shared hosting in production.
- **Decision:**
  - Frontend: Flutter (Android/iOS cross-platform).
  - Backend: Core PHP REST API (Native PHP 8.1+ using PDO).
  - Database: MySQL (`dholera_realestate`).
- **Rationale:** Core PHP provides zero framework overhead, fast execution, simple file deployment to Hostinger shared hosting without SSH server requirements, and clean REST API capability. Flutter offers single-codebase cross-platform native performance.
- **Alternatives Considered:** Laravel / Node.js Express (rejected due to deployment complexity on shared hosting).

---

## ADR 002: Authentication Architecture

- **Date:** 2026-07-31
- **Status:** Approved
- **Context:** Secure stateless API authentication for mobile client.
- **Decision:** Custom Bearer Token authentication backed by MySQL `user_tokens` table.
- **Rationale:** Avoids session cookie issues across mobile devices, permits precise token invalidation on logout or security events, and works natively in PHP without third-party JWT library overhead.
- **Alternatives Considered:** JWT (rejected to keep backend zero-dependency Core PHP).

---

## ADR 003: Flutter State Management Choice

- **Date:** 2026-07-31
- **Status:** Approved
- **Context:** State management choice for Flutter app.
- **Decision:** `provider` package (`ChangeNotifier`).
- **Rationale:** Recommended official Flutter state management solution for medium-scale apps. Low boilerplate, excellent performance, clear separation of UI and business logic.

---

## ADR 004: File Storage Strategy for Property Images

- **Date:** 2026-07-31
- **Status:** Approved
- **Context:** Property images must be stored efficiently and securely.
- **Decision:** Physical filesystem storage under `backend/uploads/properties/{property_id}/` with DB table `property_images` storing relative image paths and sort order.
- **Rationale:** Storing binary image BLOBs directly in MySQL causes severe database bloat and performance degradation. Filesystem storage is optimal and standard. Max limit set to 5 images per property.
