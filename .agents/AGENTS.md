# PROJECT RULES & WORKFLOW GUIDELINES
DHOLERA REAL ESTATE

## Automatic Version Bumping Rule (CRITICAL)
Whenever any feature, fix, or UI modification is implemented in this codebase:
1. ALWAYS automatically bump the app version (e.g. 1.0.6, 1.0.7, etc.) across ALL three configuration files BEFORE building and pushing:
   - `flutter/pubspec.yaml`
   - `flutter/lib/core/config/api_config.dart`
   - `php/api/config/version.php`
2. NEVER wait for the user to ask whether a version update is needed. Version updates MUST be automatic on every build/release cycle so live mobile app users receive in-app update notifications seamlessly.
