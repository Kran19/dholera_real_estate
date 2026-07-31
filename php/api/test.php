<?php
/**
 * Live Database Connection Test & Diagnostic Tool
 * DHOLERA REAL ESTATE
 * GET /api/test.php
 */

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/database.php';

$diagnostics = [
    "server_time" => date('Y-m-d H:i:s'),
    "php_version" => PHP_VERSION,
    "defined_constants" => [
        "DB_HOST" => DB_HOST,
        "DB_PORT" => DB_PORT,
        "DB_NAME" => DB_NAME,
        "DB_USER" => DB_USER,
        "DB_PASS_LENGTH" => strlen(DB_PASS),
    ],
    "env_vars" => [
        "ENV_DB_HOST" => $_ENV['DB_HOST'] ?? 'not_set',
        "ENV_DB_NAME" => $_ENV['DB_NAME'] ?? 'not_set',
        "ENV_DB_USER" => $_ENV['DB_USER'] ?? 'not_set',
    ],
    "connection_tests" => []
];

// Test 1: Using Database Singleton Class
try {
    $db = Database::getConnection();
    $stmt = $db->query("SELECT 1");
    $diagnostics["connection_tests"]["Database_Class"] = "SUCCESS";
} catch (Exception $e) {
    $diagnostics["connection_tests"]["Database_Class"] = "FAILED: " . $e->getMessage();
}

// Test 2: Raw Direct PDO Connection with 'localhost'
try {
    $dsn = sprintf("mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4", DB_HOST, DB_PORT, DB_NAME);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $diagnostics["connection_tests"]["Direct_Localhost_PDO"] = "SUCCESS";
} catch (PDOException $e) {
    $diagnostics["connection_tests"]["Direct_Localhost_PDO"] = "FAILED: " . $e->getMessage() . " (Code: " . $e->getCode() . ")";
}

// Test 3: Raw Direct PDO Connection with '127.0.0.1'
try {
    $dsn = sprintf("mysql:host=127.0.0.1;port=%s;dbname=%s;charset=utf8mb4", DB_PORT, DB_NAME);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $diagnostics["connection_tests"]["Direct_IP_PDO"] = "SUCCESS";
} catch (PDOException $e) {
    $diagnostics["connection_tests"]["Direct_IP_PDO"] = "FAILED: " . $e->getMessage() . " (Code: " . $e->getCode() . ")";
}

echo json_encode($diagnostics, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
