# HOSTINGER SHARED HOSTING DEPLOYMENT GUIDE — DHOLERA REAL ESTATE

This guide provides step-by-step instructions to deploy the **Core PHP REST API** to Hostinger Shared Hosting.

---

## 📁 Repository Structure Overview

```
dholera_real_estate/
├── php/                  <-- UPLOAD THIS FOLDER TO HOSTINGER (public_html/php or domain root)
│   ├── api/              <-- REST API Endpoints
│   ├── config/           <-- Database & system config
│   ├── database/         <-- SQL Schema & Seeder
│   ├── helpers/          <-- Response & upload helpers
│   ├── middleware/       <-- Auth & Admin RBAC middleware
│   └── uploads/          <-- Uploaded property images
│       └── properties/
├── flutter/              <-- FLUTTER MOBILE APP (Android APK / iOS build)
└── docs/                 <-- PROJECT DOCUMENTATION
```

---

## 🛠️ Step 1: Create Hostinger MySQL Database

1. Log into your **Hostinger hPanel**.
2. Navigate to **Databases** → **Management**.
3. Create a new MySQL database:
   - **Database Name:** e.g., `u123456789_dholera`
   - **Database Username:** e.g., `u123456789_user`
   - **Password:** Generate a strong password (e.g. `StrongPass123!`).
4. Click **Create**.

---

## 🗄️ Step 2: Import MySQL Database Schema & Initial Data

1. Open **phpMyAdmin** from your Hostinger hPanel.
2. Select your newly created database.
3. Click the **Import** tab.
4. Upload `php/database/schema.sql` and click **Go**.
5. Execute initial admin seed SQL query:
   ```sql
   INSERT INTO `users` (`username`, `password_hash`, `role`, `status`) 
   VALUES ('admin', '$2y$10$e8W1d80mB5hM2...<hashed_password>', 'super_admin', 'active');
   ```

---

## 📂 Step 3: Upload `php/` Folder to Hostinger File Manager

1. Open **File Manager** in Hostinger hPanel.
2. Navigate to `public_html/`.
3. Create a directory named `php` (or upload contents directly if serving from root domain `https://api.yourdomain.com`).
4. Upload all contents of your local `php/` directory:
   - `api/`
   - `config/`
   - `database/`
   - `helpers/`
   - `middleware/`
   - `uploads/`
5. Set directory permissions:
   - Folders: `0755`
   - Files: `0644`
   - Uploads folder (`php/uploads/properties/`): `0755` (Writable)

---

## ⚙️ Step 4: Update Production Database Credentials

Edit `public_html/php/config/database.php` on Hostinger File Manager:

```php
define('DB_HOST', 'localhost'); // Hostinger MySQL Host
define('DB_NAME', 'u123456789_dholera'); // Hostinger DB Name
define('DB_USER', 'u123456789_user');    // Hostinger DB User
define('DB_PASS', 'YourStrongPassword123!'); // Hostinger DB Password
define('DB_PORT', '3306');
```

---

## 📱 Step 5: Update Flutter App API Configuration for Production

In your Flutter project under `flutter/lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String _productionBaseUrl = 'https://yourdomain.com/php';
  
  static bool isEmulatorMode = false; // Set to false for Production build

  static String get baseUrl => isEmulatorMode ? _emulatorBaseUrl : _productionBaseUrl;
  ...
}
```

Then build production APK / App Bundle:
```bash
cd flutter
flutter build apk --release
```
