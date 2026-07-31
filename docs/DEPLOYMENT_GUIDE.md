# DHOLERA REAL ESTATE — HOSTINGER LIVE DEPLOYMENT LOG & ARCHITECTURE

> **Document Status:** Active & Preserved  
> **Last Deployment:** July 31, 2026  
> **Environment:** Hostinger Shared Hosting (Apache + FastCGI + MySQL 8.0 + PHP 8.3)  
> **Repository URL:** `https://github.com/Kran19/dholera_real_estate.git`

---

## 🌐 Live Application Links

| Application Target | Public URL |
| :--- | :--- |
| 🌐 **Live Web Application** | [https://emperorsmartsolutions.com/dholerarealestate/php/app/](https://emperorsmartsolutions.com/dholerarealestate/php/app/) |
| 📱 **Direct Android APK Download** | [https://emperorsmartsolutions.com/dholerarealestate/php/app-release.apk](https://emperorsmartsolutions.com/dholerarealestate/php/app-release.apk) |
| ⚡ **REST API Health Endpoint** | [https://emperorsmartsolutions.com/dholerarealestate/php/api/health.php](https://emperorsmartsolutions.com/dholerarealestate/php/api/health.php) |
| 🛠️ **Live DB Diagnostic Tool** | [https://emperorsmartsolutions.com/dholerarealestate/php/test.php](https://emperorsmartsolutions.com/dholerarealestate/php/test.php) |

---

## 🔑 Default Accounts & Credentials

### Live Hostinger Database Credentials (`.env`)
```ini
DB_HOST=localhost
DB_PORT=3306
DB_NAME=u362391755_dhorelareal
DB_USER=u362391755_dholerareal
DB_PASS=Emperor@Admin07
```

### Application Login Credentials
- **Super Admin:** Username `admin` | Passcode `Admin@123`
- **Normal User:** Username `user1` | Passcode `User@123`

---

## 📁 Server Directory Architecture on Hostinger

```text
/home/u362391755/domains/emperorsmartsolutions.com/public_html/dholerarealestate/
└── php/                                  <-- Git Root Repository
    ├── .env                              <-- Database Environment Config
    ├── .gitignore                        <-- Git Ignore rules
    ├── test.php                          <-- Live Visual Diagnostic Page
    ├── app-release.apk                   <-- Compiled Production Android APK (50.9 MB)
    ├── api/                              <-- Core PHP REST API Endpoints
    │   ├── auth/ (login.php, logout.php)
    │   ├── users/ (list.php, create.php, update.php, status.php, delete.php)
    │   ├── properties/ (list.php, details.php, create.php, update.php, delete.php)
    │   ├── config/ (version.php)
    │   └── health.php
    ├── app/                              <-- Compiled Production Flutter Web App
    │   ├── index.html
    │   ├── main.dart.js
    │   ├── flutter.js
    │   ├── flutter_bootstrap.js
    │   ├── flutter_service_worker.js
    │   ├── canvaskit/
    │   ├── assets/
    │   ├── icons/
    │   ├── manifest.json
    │   └── version.json
    ├── config/                           <-- PDO Singleton & Config
    │   ├── database.php
    │   └── config.php
    ├── database/                         <-- SQL Schemas & Seed Scripts
    ├── helpers/                          <-- Response, Upload, & CORS Helpers
    ├── middleware/                       <-- JWT Auth & Role Middleware
    ├── docs/                             <-- Architecture & Documentation
    └── uploads/                          <-- Property Image Uploads
        └── properties/
```

---

## 🔄 1-Step SSH Update Workflow for Future Releases

Whenever changes are made to the codebase:

```bash
# 1. SSH into Hostinger
ssh -p 6588 u362391755@emperorsmartsolutions.com

# 2. Navigate to git root
cd domains/emperorsmartsolutions.com/public_html/dholerarealestate/php

# 3. Pull latest changes
git pull origin main
```

---

## 📌 Versioning Rule

Whenever making new feature changes:
1. Increment version string in:
   - `flutter/lib/core/config/api_config.dart` (`currentAppVersion = "X.Y.Z"`)
   - `php/api/config/version.php` (`latest_version = "X.Y.Z"`)
2. All mobile users automatically get an in-app popup: **"New Update Available! [Update Now]"**.
