# FLUTTER ARCHITECTURE DOCUMENTATION — DHOLERA REAL ESTATE

---

## 1. Directory Structure Standard

```
lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── api_config.dart          # Base URLs, timeouts, API endpoints
│   ├── constants/
│   │   ├── app_colors.dart          # Primary, secondary, dark/light theme tokens
│   │   ├── app_styles.dart          # Modern typography (Google Fonts Inter/Outfit)
│   │   └── app_assets.dart          # Logo & asset paths
│   ├── network/
│   │   ├── api_client.dart          # Centralized HTTP client (http package)
│   │   └── api_exceptions.dart      # Custom exception definitions
│   ├── storage/
│   │   └── secure_storage_service.dart # Encrypted token & user persistence
│   └── utils/
│       ├── validation_utils.dart    # Form & input validators
│       └── ui_helpers.dart          # Snackbars, modal dialogs, formatters
├── models/
│   ├── user_model.dart              # User entity JSON deserialization
│   ├── property_model.dart          # Property entity JSON deserialization
│   └── property_image_model.dart    # Image metadata deserialization
├── services/
│   ├── auth_service.dart            # Raw auth API calls
│   ├── user_service.dart            # Raw user management API calls
│   └── property_service.dart        # Raw property & image API calls
├── providers/
│   ├── auth_provider.dart          # Authentication state management
│   ├── user_provider.dart          # User list & CRUD state management
│   └── property_provider.dart      # Property list, pagination, filter & CRUD state
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart       # App initialization & auth state check
│   ├── auth/
│   │   └── login/
│   │       └── login_screen.dart    # Login form with validation
│   ├── admin/
│   │   └── dashboard/
│   │       └── admin_dashboard_screen.dart # Admin metrics & main actions
│   ├── users/
│   │   ├── user_list_screen.dart    # Super Admin user management
│   │   └── create_edit_user_screen.dart
│   ├── properties/
│   │   ├── property_list_screen.dart   # Infinite scroll property list & search
│   │   ├── property_details_screen.dart# Full property details & image gallery
│   │   └── add_edit_property_screen.dart # Form + image picker (max 5)
│   └── profile/
│       └── profile_screen.dart       # User info & logout action
└── widgets/
    ├── property_card.dart           # Reusable property card widget
    ├── custom_button.dart           # Primary & secondary button styles
    ├── custom_text_field.dart       # Form input fields with validation
    ├── loading_widget.dart          # Modern shimmer/spinner loading state
    ├── empty_state.dart             # Custom empty list placeholder
    ├── error_state.dart             # Retryable error screen widget
    └── image_gallery_viewer.dart    # Full-screen photo viewer widget
```

---

## 2. State Management Architecture

We use **Provider** (`provider` package) to maintain clear layer separation:

- **UI Widgets:** Pure presentation components. Never make HTTP calls or handle raw JSON directly.
- **Providers (`ChangeNotifier`):** Manage state, handle loading indicators, error messages, pagination logic, and notify listeners.
- **Services:** Execute network requests via `ApiClient` and map responses to typed Models.
- **Models:** Strongly typed Dart data objects with `fromJson()` and `toJson()` constructors.

---

## 3. Network Layer (`ApiClient`) Design

Centralized HTTP client responsibilities:

1. **Base URL Resolution:**
   - Android Emulator: `http://10.0.2.2/dholera_real_estate/backend`
   - Physical Device / LAN: `http://192.168.x.x/dholera_real_estate/backend`
   - Configurable at runtime or environment config.
2. **Automatic Header Injection:**
   - Adds `Content-Type: application/json` or `multipart/form-data`.
   - Adds `Authorization: Bearer <token>` from `SecureStorageService`.
3. **Unified Response & Error Normalization:**
   - Catch network timeouts (15s default).
   - Handles HTTP 401 (Session Expired), 403 (Forbidden), 404 (Not Found), 500 (Server Error).
   - Deserializes standard API format `{ success, message, data, errors, pagination }`.
