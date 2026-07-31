<?php
/**
 * DHOLERA REAL ESTATE — LIVE DIAGNOSTIC & DATABASE TESTER
 * URL: /api/test.php or /test.php
 */

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

header('Content-Type: text/html; charset=utf-8');

echo "<!DOCTYPE html><html><head><title>Dholera Real Estate — DB Diagnostic</title>";
echo "<style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;padding:2rem;} .card{background:#1e293b;padding:1.5rem;border-radius:12px;margin-bottom:1rem;border:1px solid #334155;} .success{color:#4ade80;} .danger{color:#f87171;} pre{background:#020617;padding:1rem;border-radius:8px;overflow-x:auto;color:#e2e8f0;}</style></head><body>";

echo "<h1>🛠️ Dholera Real Estate — Database Diagnostic</h1>";

require_once __DIR__ . '/../config/database.php';

echo "<div class='card'>";
echo "<h3>1. Environment & Database Configuration</h3>";
echo "<ul>";
echo "<li><strong>Server Name:</strong> " . htmlspecialchars($_SERVER['SERVER_NAME'] ?? 'CLI') . "</li>";
echo "<li><strong>PHP Version:</strong> " . PHP_VERSION . "</li>";
echo "<li><strong>DB Host:</strong> " . htmlspecialchars(DB_HOST) . "</li>";
echo "<li><strong>DB Port:</strong> " . htmlspecialchars(DB_PORT) . "</li>";
echo "<li><strong>DB Name:</strong> " . htmlspecialchars(DB_NAME) . "</li>";
echo "<li><strong>DB User:</strong> " . htmlspecialchars(DB_USER) . "</li>";
echo "<li><strong>DB Pass Length:</strong> " . strlen(DB_PASS) . " characters</li>";
echo "</ul>";
echo "</div>";

echo "<div class='card'>";
echo "<h3>2. Database Singleton Connection Test</h3>";
try {
    $db = Database::getConnection();
    echo "<p class='success'>✅ SUCCESS: Database::getConnection() connected successfully to MySQL!</p>";
    
    // Check tables
    $tables = $db->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    echo "<p><strong>Existing Tables (" . count($tables) . "):</strong> " . implode(', ', $tables) . "</p>";
    
    if (in_array('users', $tables)) {
        $userCount = $db->query("SELECT COUNT(*) FROM users")->fetchColumn();
        echo "<p>👥 Total Users in Database: <strong>$userCount</strong></p>";
    }
    
    if (in_array('properties', $tables)) {
        $propCount = $db->query("SELECT COUNT(*) FROM properties")->fetchColumn();
        echo "<p>🏢 Total Properties in Database: <strong>$propCount</strong></p>";
    }

} catch (Throwable $e) {
    echo "<p class='danger'>❌ FAILED: Database connection error!</p>";
    echo "<pre>";
    echo "Error Class: " . get_class($e) . "\n";
    echo "Error Message: " . htmlspecialchars($e->getMessage()) . "\n";
    echo "Error Code: " . $e->getCode() . "\n";
    echo "File: " . $e->getFile() . " (Line " . $e->getLine() . ")\n";
    echo "\nTrace:\n" . htmlspecialchars($e->getTraceAsString());
    echo "</pre>";
}
echo "</div>";

echo "<div class='card'>";
echo "<h3>3. Direct PDO Raw Connection Test</h3>";
try {
    $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
    $rawPdo = new PDO($dsn, DB_USER, DB_PASS, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    echo "<p class='success'>✅ SUCCESS: Direct PDO connection to " . htmlspecialchars(DB_NAME) . " succeeded!</p>";
} catch (PDOException $pe) {
    echo "<p class='danger'>❌ FAILED: Raw PDO Error!</p>";
    echo "<pre>";
    echo "PDO Error Code: " . $pe->getCode() . "\n";
    echo "PDO Error Message: " . htmlspecialchars($pe->getMessage()) . "\n";
    echo "</pre>";
}
echo "</div>";

echo "</body></html>";
