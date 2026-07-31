<?php
/**
 * DHOLERA REAL ESTATE — DATABASE MIGRATION SCRIPT
 * URL: /migrate.php or /api/migrate.php
 * 
 * Safely creates or updates the `inquiries` table.
 */

require_once __DIR__ . '/bootstrap.php';

header('Content-Type: text/html; charset=utf-8');

echo "<!DOCTYPE html><html><head><title>Database Migration — Dholera Real Estate</title>";
echo "<style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;padding:2rem;} .card{background:#1e293b;padding:1.5rem;border-radius:12px;margin-bottom:1rem;border:1px solid #334155;} .success{color:#4ade80;} .danger{color:#f87171;} pre{background:#020617;padding:1rem;border-radius:8px;overflow-x:auto;color:#e2e8f0;}</style></head><body>";

echo "<h1>🚀 Dholera Real Estate — Database Migration</h1>";

try {
    $db = Database::getConnection();
    echo "<div class='card'>";
    echo "<p class='success'>✅ Connected to database: <strong>" . htmlspecialchars(DB_NAME) . "</strong></p>";

    // Disable foreign key checks temporarily to guarantee clean migration
    $db->exec("SET FOREIGN_KEY_CHECKS = 0;");

    // 1. Create inquiries table if not exists
    $sqlCreate = "
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
            INDEX idx_inquiries_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $db->exec($sqlCreate);
    echo "<p class='success'>✅ Table `inquiries` created or verified successfully!</p>";

    // 2. Ensure requirement column exists
    $cols = $db->query("SHOW COLUMNS FROM inquiries LIKE 'requirement'")->fetch();
    if (!$cols) {
        $db->exec("ALTER TABLE inquiries ADD COLUMN requirement TEXT NULL AFTER customer_mobile;");
        echo "<p class='success'>✅ Column `requirement` added to `inquiries` table!</p>";
    } else {
        echo "<p class='success'>✅ Column `requirement` is present.</p>";
    }

    // Re-enable foreign key checks
    $db->exec("SET FOREIGN_KEY_CHECKS = 1;");

    echo "<h2 class='success'>🎉 ALL MIGRATIONS COMPLETED SUCCESSFULLY!</h2>";
    echo "</div>";

} catch (Throwable $e) {
    echo "<div class='card'>";
    echo "<p class='danger'>❌ Migration Error!</p>";
    echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
    echo "</div>";
}

echo "</body></html>";
