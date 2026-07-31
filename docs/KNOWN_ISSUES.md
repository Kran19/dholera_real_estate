# KNOWN ISSUES & WORKAROUNDS — DHOLERA REAL ESTATE

---

## Active Known Issues

Currently, there are no open runtime bugs as the application foundation is in Phase 0 (Documentation & Foundation Setup).

---

## Architectural Constraints & Watch items

1. **Android Emulator Local Host IP:**
   - *Constraint:* Android Emulators map `localhost` to the internal emulator loopback.
   - *Solution:* Flutter network config uses `http://10.0.2.2/dholera_real_estate/backend` for emulator testing and local Wi-Fi IP (e.g., `192.168.x.x`) for physical devices.

2. **CORS Header Configuration:**
   - *Constraint:* Web/emulator clients during development may trigger HTTP CORS pre-flight OPTIONS requests.
   - *Solution:* Backend helper `backend/helpers/response.php` includes proper CORS headers (`Access-Control-Allow-Origin: *`, `Access-Control-Allow-Headers: Authorization, Content-Type`).

3. **Shared Hosting Image Directory Permissions:**
   - *Constraint:* Hostinger file permissions require `0755` for directories and `0644` for uploaded image files.
   - *Solution:* Backend image upload helper explicitly applies `chmod()` when creating property directories.
