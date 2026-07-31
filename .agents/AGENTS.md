# PROJECT RULES & WORKFLOW GUIDELINES
DHOLERA REAL ESTATE

## 1. Automatic Version Bumping Rule (CRITICAL)
Whenever any feature, fix, or UI modification is implemented in this codebase:
1. ALWAYS automatically bump the app version (e.g. 1.0.8, 1.0.9, etc.) across ALL three configuration files BEFORE building and pushing:
   - `flutter/pubspec.yaml`
   - `flutter/lib/core/config/api_config.dart`
   - `php/api/config/version.php`
2. **Version Synchronization Standard:** The compiled Flutter app version (`currentAppVersion` in `api_config.dart`) MUST EXACTLY MATCH the server version (`latest_version` in `version.php`) during release builds. Never set `latest_version` higher than the compiled APK version unless intentionally triggering an update popup for older clients.
3. NEVER wait for the user to ask whether a version update is needed. Version updates MUST be automatic on every build/release cycle so live mobile app users receive in-app update notifications seamlessly.

## 2. Direct Phone Dialing Intent & Permission Standard
1. Preserve `android.permission.CALL_PHONE` and `<intent><action android:name="android.intent.action.DIAL" /><data android:scheme="tel" /></intent>` in `flutter/android/app/src/main/AndroidManifest.xml`.
2. Use `LaunchMode.externalApplication` when launching `tel:` scheme URIs via `url_launcher` so Android opens the native phone dialer directly.

## 3. Dynamic APK Serving Standard
1. Always route APK downloads through `php/download_apk.php` rather than static file links.
2. `php/download_apk.php` must stream binary data using 8KB `fread()` chunks with `Content-Length` headers and dynamically parse `$latestVersion` from `version.php` for filenames (e.g., `DholeraRealEstate-v1.0.8.apk`).
