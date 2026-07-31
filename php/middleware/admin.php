<?php
/**
 * Super Admin Authorization Middleware
 * DHOLERA REAL ESTATE
 */

require_once __DIR__ . '/../bootstrap.php';

// Requires auth.php to have executed first
if (!isset($currentUser) || empty($currentUser)) {
    sendJsonResponse(false, "Unauthorized: Authentication context missing.", null, 401);
}

if ($currentUser['role'] !== 'super_admin') {
    sendJsonResponse(false, "Forbidden: Super Admin privileges are required to perform this action.", null, 403);
}
