<?php
/**
 * Migration 002: Create Customer Inquiries Table
 * DHOLERA REAL ESTATE — Name, City, Mobile, Requirement, Notes, Creator
 */

return function(PDO $db) {
    $db->exec("
        CREATE TABLE IF NOT EXISTS inquiries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_name VARCHAR(100) NOT NULL,
            customer_city VARCHAR(100) NOT NULL,
            customer_mobile VARCHAR(20) NOT NULL,
            requirement TEXT NULL,
            notes TEXT NULL,
            created_by INT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_inquiries_created_at (created_at),
            INDEX idx_inquiries_mobile (customer_mobile)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    // Add requirement column safely if missing on existing instances
    $cols = $db->query("SHOW COLUMNS FROM inquiries LIKE 'requirement'")->fetch();
    if (!$cols) {
        $db->exec("ALTER TABLE inquiries ADD COLUMN requirement TEXT NULL AFTER customer_mobile;");
    }
};
