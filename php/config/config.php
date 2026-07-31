<?php
/**
 * Global Backend System Configuration
 * DHOLERA REAL ESTATE
 */

// Application Constants
define('APP_NAME', 'DHOLERA REAL ESTATE');
define('APP_VERSION', '1.0.0');

// Environment Settings
define('IS_DEVELOPMENT', true);

// Token Expiry (30 Days in seconds)
define('TOKEN_EXPIRY_SECONDS', 30 * 24 * 60 * 60);

// File Upload Constraints
define('UPLOAD_DIR', __DIR__ . '/../uploads/properties');
define('MAX_PROPERTY_IMAGES', 5);
define('MAX_FILE_SIZE_BYTES', 5 * 1024 * 1024); // 5 MB
define('ALLOWED_MIME_TYPES', ['image/jpeg', 'image/png', 'image/webp']);
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'webp']);

// Base URL detection helper
function getBaseUrl(): string {
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    
    // Default relative path for WAMP / local web server
    $scriptDir = dirname($_SERVER['SCRIPT_NAME'] ?? '');
    $basePath = preg_replace('#/api(/.*)?$#', '', $scriptDir);

    return rtrim($protocol . '://' . $host . $basePath, '/');
}
