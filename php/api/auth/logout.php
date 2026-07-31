<?php
/**
 * User Logout Endpoint
 * DHOLERA REAL ESTATE
 * POST /api/auth/logout.php
 */

require_once __DIR__ . '/../../middleware/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

try {
    if (!empty($token)) {
        revokeToken($token);
    }
    sendJsonResponse(true, "Logged out successfully.", null);
} catch (Exception $e) {
    error_log("Logout error: " . $e->getMessage());
    sendJsonResponse(false, "Logout failed.", null, 500);
}
