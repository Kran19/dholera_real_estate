# LOCAL DEVELOPMENT ENVIRONMENT SETUP — DHOLERA REAL ESTATE

---

## 1. Prerequisites

- **PHP:** PHP 8.1+ with extensions `pdo`, `pdo_mysql`, `gd`, `fileinfo`, `json`, `mbstring`.
- **Database:** MySQL 8.0+ or MariaDB 10.4+ (XAMPP / WAMP / Laragon / Local MySQL).
- **Web Server:** Apache / Nginx / PHP Built-in Server.
- **SDK:** Flutter SDK 3.19+ & Dart SDK.
- **IDE:** VS Code / Android Studio.

---

## 2. Backend & Database Setup Steps

### Step 1: Clone / Navigate to Workspace
Root directory: `c:\Users\Admin\Desktop\projects\APPLICATIONS\dholera_real_estate`

### Step 2: Database Creation
1. Open phpMyAdmin or MySQL CLI (`mysql -u root`).
2. Create database:
   ```sql
   CREATE DATABASE IF NOT EXISTS `dholera_realestate` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
3. Import initial schema script from `backend/database/schema.sql` (to be generated in Phase 1).

### Step 3: Backend Configuration
Inspect `backend/config/database.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'dholera_realestate');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_PORT', '3306');
```

### Step 4: Web Server Virtual Host / Directory Setup
Option A (XAMPP/htdocs):
Copy or symlink `backend` folder to `C:/xampp/htdocs/dholera_real_estate/backend`.

Option B (PHP Built-in Server for fast local testing):
```bash
cd backend
php -S localhost:8080
```

---

## 3. Flutter Configuration & Emulator Networking

### Base URL Matrix:

| Environment | Base URL |
| :--- | :--- |
| **Android Emulator (XAMPP Default)** | `http://10.0.2.2/dholera_real_estate/backend` |
| **Android Emulator (PHP CLI `localhost:8080`)** | `http://10.0.2.2:8080` |
| **iOS Simulator** | `http://localhost/dholera_real_estate/backend` |
| **Physical Android Device (Same Wi-Fi)** | `http://<YOUR_LOCAL_IP>/dholera_real_estate/backend` |

Configure in `lib/core/config/api_config.dart`.

---

## 4. Run & Test Instructions

### Step 1: Verify Backend Health
Open browser and navigate to:
`http://localhost/dholera_real_estate/backend/api/health.php`
Expected response: `{ "status": "ok", "database": "connected" }`.

### Step 2: Launch Flutter App
```bash
flutter pub get
flutter run
```

### Default Credentials:
- **Username:** `admin`
- **Passcode:** `Admin@123`
