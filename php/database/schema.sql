-- ============================================================
-- DHOLERA REAL ESTATE — DATABASE SCHEMA DDL
-- Database Name: dholera_realestate
-- MySQL Version: 8.0+ / MariaDB 10.4+
-- Engine: InnoDB
-- Charset: utf8mb4_unicode_ci
-- ============================================================

CREATE DATABASE IF NOT EXISTS `dholera_realestate` 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE `dholera_realestate`;

-- ------------------------------------------------------------
-- Table 1: users
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- Table 2: user_tokens
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_tokens` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `token` VARCHAR(128) NOT NULL UNIQUE,
  `expires_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_token_expires` (`token`, `expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Table 3: properties
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- Table 4: property_images
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `property_images` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `property_id` INT UNSIGNED NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  INDEX `idx_property_images` (`property_id`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
