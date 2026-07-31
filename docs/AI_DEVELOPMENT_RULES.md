# MANDATORY AI DEVELOPMENT RULES — DHOLERA REAL ESTATE

These rules are mandatory for all AI software engineers working on this repository.

---

## 15 MANDATORY DEVELOPMENT RULES

1. **RULE 1 — UNDERSTAND BEFORE MODIFYING:** Never make significant code changes before fully understanding the existing architecture, documentation, database schema, and Flutter structure.
2. **RULE 2 — READ DOCUMENTATION FIRST:** Always read `docs/PROJECT_MEMORY.md`, `docs/ARCHITECTURE.md`, and relevant doc files before writing or editing code.
3. **RULE 3 — SEARCH REPOSITORY BEFORE CREATING:** Search existing files, helper functions, and classes before creating new ones to prevent code duplication.
4. **RULE 4 — REUSE EXISTING ARCHITECTURE:** Consistently reuse established patterns (`ApiClient`, `Provider`, PDO prepared statements, standard JSON responses).
5. **RULE 5 — NO DUPLICATE FUNCTIONALITY:** Do not create duplicate API endpoints, duplicate database queries, or duplicate Flutter widgets.
6. **RULE 6 — EVALUATE PACKAGE ADDITIONS:** Do not introduce new Flutter packages or PHP libraries without evaluating necessity and obtaining user approval.
7. **RULE 7 — NO CASUAL SCHEMA CHANGES:** Do not modify database tables or column types without documenting changes in `docs/DATABASE_SCHEMA.md` and updating PHP & Flutter models.
8. **RULE 8 — KEEP CONTRACTS SYNCHRONIZED:** Never modify an API response or parameter without updating the PHP backend, Flutter model, and `docs/API_DOCUMENTATION.md` simultaneously.
9. **RULE 9 — PRESERVE SECURITY IMPLICATIONS:** Never bypass or alter authentication (`middleware/auth.php`) or role-based authorization (`middleware/admin.php`).
10. **RULE 10 — RESPECT BRANDING & LOGO:** Do not modify, redraw, colorize, or replace the official project logo (`assets/images/logo.png`).
11. **RULE 11 — PRESERVE EXISTING FUNCTIONALITY:** Do not delete existing features, fields, or endpoints unless explicitly instructed by the user.
12. **RULE 12 — ANALYZE SIDE EFFECTS:** Identify all affected Flutter screens, PHP files, and DB queries before implementing any change (Impact Analysis).
13. **RULE 13 — VERIFY AFTER IMPLEMENTATION:** Verify compilation, syntax correctness, API contract compliance, and error handling after every modification.
14. **RULE 14 — ALWAYS UPDATE DOCUMENTATION:** Update `docs/PROJECT_MEMORY.md`, `docs/CHANGELOG.md`, and affected documentation immediately after completing significant changes.
15. **RULE 15 — EXPLAIN AMBIGUITY BEFORE CODING:** If requirements are ambiguous, stop and explain the ambiguity instead of making risky assumptions.
