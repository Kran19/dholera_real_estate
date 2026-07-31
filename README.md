# DHOLERA REAL ESTATE 🏢

A complete, high-performance real estate property management system for Dholera SIR, featuring a **Core PHP REST API backend**, **MySQL database**, and a **cross-platform Flutter Web & Android application**.

---

## 🌟 Key Features

- 📱 **Cross-Platform Support:** Single codebase for Android mobile app & Web browser portal.
- 🔐 **Secure Role-Based Access Control:** Super Admin and User authentication via JWT session tokens.
- 🏘️ **Property Management:** Full CRUD operations for village names, survey numbers, zone designations, TP/FP plots, and area measurements (Sq Yard / Bigha).
- 📸 **Photo Gallery Uploads:** Multi-image upload & management using cross-platform memory bytes (`Uint8List`).
- 📐 **Customizable Grid View:** Toggleable 1-column, 2-column, and 4-column responsive layout grids.
- 🔄 **Automatic In-App Update Checker:** Built-in mobile update detection with 1-click APK download prompts.

---

## 📁 Repository Structure

```
dholera_real_estate/
├── php/                         # Core PHP REST API & Backend
│   ├── api/                     # REST API Endpoints (auth, users, properties, config)
│   ├── config/                  # Database & Environment configuration
│   ├── helpers/                 # Upload, validation, & response helpers
│   ├── middleware/              # Auth & CORS middleware
│   └── uploads/                 # Uploaded property images
├── flutter/                     # Flutter Web & Mobile Application
│   ├── lib/                     # Dart source code (providers, models, screens, services)
│   ├── android/                 # Android native configuration & AndroidManifest
│   └── web/                     # Web entry point
├── docs/                        # Live Database SQL & Hostinger Deployment Guide
└── README.md
```

---

## 🔑 Default Credentials

- **Super Admin:** Username `admin` | Passcode `Admin@123`
- **Normal User:** Username `user1` | Passcode `User@123`
