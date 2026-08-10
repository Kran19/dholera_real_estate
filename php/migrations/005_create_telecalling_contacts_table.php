<?php
/**
 * Migration 005: Create Telecalling Contacts & Call Logs Tables
 * DHOLERA REAL ESTATE — Dedicated Telecalling Contacts & 10-Day Rotation System
 */

return function(PDO $db) {
    // 1. Telecalling Contacts Table (Cold calling leads pool)
    $db->exec("
        CREATE TABLE IF NOT EXISTS telecalling_contacts (
            id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name        VARCHAR(255) NOT NULL,
            mobile      VARCHAR(20) NOT NULL,
            city        VARCHAR(100) NULL,
            notes       TEXT NULL,
            status      ENUM('pending', 'called', 'interested', 'not_interested', 'moved_to_inquiry') NOT NULL DEFAULT 'pending',
            created_by  INT NOT NULL,
            created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX       idx_status (status),
            INDEX       idx_mobile (mobile),
            INDEX       idx_created_by (created_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    // 2. Telecalling Call Logs Table (Daily status per contact)
    $db->exec("
        CREATE TABLE IF NOT EXISTS telecalling_call_logs (
            id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            contact_id  INT NOT NULL,
            called_date DATE NOT NULL,
            status      ENUM('received','pending','no_answer','callback','not_interested','confirmed') NOT NULL DEFAULT 'pending',
            remarks     TEXT NULL,
            created_by  INT NOT NULL,
            created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY  uq_contact_date_user (contact_id, called_date, created_by),
            INDEX       idx_called_date (called_date),
            INDEX       idx_contact_id (contact_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
};
