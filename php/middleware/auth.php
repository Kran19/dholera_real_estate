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

// Extract HTTP Authorization header with cross-platform FastCGI & Apache fallbacks
$headers = function_exists('getallheaders') ? getallheaders() : [];
$authHeader = $_SERVER['HTTP_AUTHORIZATION'] 
    ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] 
    ?? $headers['Authorization'] 
    ?? $headers['authorization'] 
    ?? $_SERVER['HTTP_X_AUTH_TOKEN']
    ?? $headers['X-Auth-Token']
    ?? $headers['x-auth-token']
    ?? '';

$token = '';
$input = getJsonInput();

if (preg_match('/Bearer\s+(\S+)/i', $authHeader, $matches)) {
    $token = trim($matches[1]);
} else if (!empty($authHeader)) {
    $token = trim($authHeader);
} else if (is_array($input) && !empty($input['token'])) {
    $token = trim($input['token']);
} else if (!empty($_POST['token'])) {
    $token = trim($_POST['token']);
} else if (!empty($_GET['token'])) {
    $token = trim($_GET['token']);
}

if (empty($token)) {
    sendJsonResponse(false, "Unauthorized: Authentication token is missing.", null, 401);
}

$currentUser = validateToken($token);

if (!$currentUser) {
    sendJsonResponse(false, "Unauthorized: Invalid, expired, or deactivated token session.", null, 401);
}

// $currentUser is now globally accessible to downstream endpoints
