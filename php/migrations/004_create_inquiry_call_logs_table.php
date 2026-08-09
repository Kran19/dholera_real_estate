<?php
/**
 * Migration 004: Create Inquiry Call Logs Table
 * DHOLERA REAL ESTATE — Stores daily 10-contact call log status & remarks
 */

return function(PDO $db) {
    $db->exec("
        CREATE TABLE IF NOT EXISTS inquiry_call_logs (
            id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            inquiry_id  INT NOT NULL,
            called_date DATE NOT NULL,
            status      ENUM('received','pending','no_answer','callback','not_interested') NOT NULL DEFAULT 'pending',
            remarks     TEXT NULL,
            created_by  INT NOT NULL,
            created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY  uq_inquiry_date_user (inquiry_id, called_date, created_by),
            INDEX       idx_called_date (called_date),
            INDEX       idx_inquiry_id (inquiry_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
};
