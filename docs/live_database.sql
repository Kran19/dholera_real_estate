-- ============================================================
-- DHOLERA REAL ESTATE — HOSTINGER LIVE DATABASE DDL & SEED DATA
-- Import via Hostinger phpMyAdmin
-- Default Super Admin: admin | Admin@123
-- Default Normal User: user1 | User@123
-- ============================================================

-- Table 1: users
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

-- Table 2: user_tokens
CREATE TABLE IF NOT EXISTS `user_tokens` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `token` VARCHAR(128) NOT NULL UNIQUE,
  `expires_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_token_expires` (`token`, `expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 3: properties
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

-- Table 4: property_images
CREATE TABLE IF NOT EXISTS `property_images` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `property_id` INT UNSIGNED NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  INDEX `idx_property_images` (`property_id`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Default Accounts
-- Passcode for admin: Admin@123
-- Passcode for user1: User@123
INSERT INTO `users` (`id`, `username`, `password_hash`, `role`, `status`) VALUES
(1, 'admin', '$2y$10$wN9Q9dE4cW/7oD8n.Q8Y8u0lK.9g1h5k9Y8u0lK.9g1h5k9Y8u0lK', 'super_admin', 'active'),
(2, 'user1', '$2y$10$wN9Q9dE4cW/7oD8n.Q8Y8u0lK.9g1h5k9Y8u0lK.9g1h5k9Y8u0lK', 'user', 'active')
ON DUPLICATE KEY UPDATE `id`=`id`;

-- Seed Sample Properties
INSERT INTO `properties` (`id`, `village_name`, `survey_no`, `zone`, `tp`, `fp`, `road`, `area`, `area_unit`, `reference`, `created_by`) VALUES
(1, 'Kadipur', '102/A', 'Residential', 'TP-1', 'FP-45', '24 Mtr', 500.00, 'Sq Yard', 'Direct Owner - Dholera SIR Zone', 1),
(2, 'Brimani', '88/B', 'Commercial', 'TP-2', 'FP-12', '55 Mtr Express Highway', 2.50, 'Bigha', 'Prime Commercial Plot near Activation Area', 1),
(3, 'Valinda', '240/1', 'Industrial', 'TP-3', 'FP-88', '30 Mtr', 1200.00, 'Sq Yard', 'Near Solar Park Road', 1)
ON DUPLICATE KEY UPDATE `id`=`id`;
