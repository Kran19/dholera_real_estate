# DATABASE SCHEMA DOCUMENTATION — DHOLERA REAL ESTATE

- **Database Name:** `dholera_realestate`
- **Database Engine:** MySQL 8.0+ / MariaDB 10.4+ (InnoDB Engine, `utf8mb4_unicode_ci` charset)
- **Local Host:** `localhost:3306`
- **User:** `root`
- **Password:** `(EMPTY)`

---

## 1. Table Definitions

### A. Table: `users`
Stores user accounts for Super Admins and regular Users.

```sql
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('super_admin', 'user') NOT NULL DEFAULT 'user',
  `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_username` (`username`),
  INDEX `idx_status_role` (`status`, `role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### Field Specifications:
| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `id` | INT UNSIGNED AUTO_INCREMENT | NO | Primary key |
| `username` | VARCHAR(50) | NO | Unique login username |
| `password_hash` | VARCHAR(255) | NO | Hashed password (`password_hash()`) |
| `role` | ENUM('super_admin', 'user') | NO | Account access level |
| `status` | ENUM('active', 'inactive') | NO | Account active status flag |
| `created_at` | DATETIME | NO | Timestamp of creation |
| `updated_at` | DATETIME | NO | Timestamp of last update |

---

### B. Table: `user_tokens`
Stores active authentication tokens for users.

```sql
CREATE TABLE IF NOT EXISTS `user_tokens` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `token` VARCHAR(128) NOT NULL UNIQUE,
  `expires_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_token_expires` (`token`, `expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### C. Table: `properties`
Stores core real estate property listing details.

```sql
CREATE TABLE IF NOT EXISTS `properties` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `village_name` VARCHAR(100) NOT NULL,
  `survey_no` VARCHAR(100) NOT NULL,
  `zone` VARCHAR(100) NOT NULL,
  `tp` VARCHAR(100) DEFAULT NULL,
  `fp` VARCHAR(100) DEFAULT NULL,
  `road` VARCHAR(100) NOT NULL,
  `area` DECIMAL(12, 2) NOT NULL,
  `area_unit` VARCHAR(30) NOT NULL DEFAULT 'Sq Yard',
  `reference` VARCHAR(255) DEFAULT NULL,
  `landing_price` VARCHAR(100) DEFAULT NULL,
  `created_by` INT UNSIGNED DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  INDEX `idx_village` (`village_name`),
  INDEX `idx_survey` (`survey_no`),
  INDEX `idx_zone` (`zone`),
  INDEX `idx_area_unit` (`area_unit`),
  INDEX `idx_reference` (`reference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### Field Specifications:
| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `id` | INT UNSIGNED AUTO_INCREMENT | NO | Primary key |
| `village_name` | VARCHAR(100) | NO | Name of the village |
| `survey_no` | VARCHAR(100) | NO | Land survey number |
| `zone` | VARCHAR(100) | NO | Real estate zone designation |
| `tp` | VARCHAR(100) | YES | Town Planning scheme identifier |
| `fp` | VARCHAR(100) | YES | Final Plot number |
| `road` | VARCHAR(100) | NO | Road width or road access info |
| `area` | DECIMAL(12,2) | NO | Numeric area measure |
| `area_unit` | VARCHAR(30) | NO | Unit of measurement (`Sq Yard`, `Bigha`, etc.) |
| `reference` | VARCHAR(255) | YES | Agent/Source reference details |
| `landing_price` | VARCHAR(100) | YES | Landing price details (Admin visible only) |
| `created_by` | INT UNSIGNED | YES | Foreign key referencing user who created property |
| `created_at` | DATETIME | NO | Creation timestamp |
| `updated_at` | DATETIME | NO | Last modified timestamp |

---

### D. Table: `property_images`
Stores image references associated with properties (Maximum 5 images per property).

```sql
CREATE TABLE IF NOT EXISTS `property_images` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `property_id` INT UNSIGNED NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  INDEX `idx_property_images` (`property_id`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2. Foreign Key & Integrity Constraints

1. **`property_images.property_id` → `properties.id`**: `ON DELETE CASCADE`. When a property record is removed, associated image metadata records in DB are automatically removed.
2. **`properties.created_by` → `users.id`**: `ON DELETE SET NULL`. If a user is deleted, property listings remain intact with `created_by = NULL`.
3. **`user_tokens.user_id` → `users.id`**: `ON DELETE CASCADE`. If a user account is deleted, all active tokens are revoked instantly.

---

## 3. Database Initial Seed Data

Default Super Admin user (Password: `Admin@123`):
```sql
INSERT INTO `users` (`username`, `password_hash`, `role`, `status`) 
VALUES ('admin', '$2y$10$e8W1d80mB5hM2...<hashed_password>', 'super_admin', 'active');
```
*(Exact hash will be generated securely during backend initialization script run).*
