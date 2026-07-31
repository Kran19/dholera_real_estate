<?php
/**
 * Authentication Middleware
 * DHOLERA REAL ESTATE
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

handleCorsPreflight();

// Extract HTTP Authorization header (Checking $_SERVER and getallheaders for Apache/WAMP/Hostinger compatibility)
$headers = function_exists('getallheaders') ? getallheaders() : [];
$authHeader = $_SERVER['HTTP_AUTHORIZATION'] 
    ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] 
    ?? $headers['Authorization'] 
    ?? $headers['authorization'] 
    ?? '';
$token = '';

if (preg_match('/Bearer\s+(\S+)/i', $authHeader, $matches)) {
    $token = trim($matches[1]);
}

if (empty($token)) {
    sendJsonResponse(false, "Unauthorized: Authentication token is missing.", null, 401);
}

$currentUser = validateToken($token);

if (!$currentUser) {
    sendJsonResponse(false, "Unauthorized: Invalid, expired, or deactivated token session.", null, 401);
}

// $currentUser is now globally accessible to downstream endpoints
