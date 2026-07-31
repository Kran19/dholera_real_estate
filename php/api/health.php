<?php
/**
 * System Health Check Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/health.php
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../helpers/response.php';

handleCorsPreflight();

try {
    $db = Database::getConnection();
    $stmt = $db->query("SELECT 1");
    
    sendJsonResponse(true, "DHOLERA REAL ESTATE API is operational", [
        "app_name" => APP_NAME,
        "version"  => APP_VERSION,
        "database" => "connected",
        "timestamp"=> date('Y-m-d H:i:s')
    ]);
} catch (Exception $e) {
    sendJsonResponse(false, "API Health check failed: " . $e->getMessage(), null, 500);
}
