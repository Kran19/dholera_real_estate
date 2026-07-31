<?php
/**
 * Master Application Bootstrap Loader
 * DHOLERA REAL ESTATE
 * 
 * Centralizes all core dependencies, security headers, output buffering,
 * error handling, database connection, validation, and authentication helpers.
 */

// 1. Output Buffering & Global Error/Exception Interceptors
require_once __DIR__ . '/helpers/response.php';

// 2. Global Configuration Constants & Base URL Detection
require_once __DIR__ . '/config/config.php';

// 3. Database Singleton Connection & Environment Detection
require_once __DIR__ . '/config/database.php';

// 4. Input Validation & Sanitization Helpers (getJsonInput, sanitizeString, validateRequired)
require_once __DIR__ . '/helpers/validation.php';

// 5. Authentication Token Helpers (generateBearerToken, createSessionToken, validateToken, revokeToken)
require_once __DIR__ . '/helpers/auth.php';

// 6. File Upload Helpers (validateUploadedImage, savePropertyImage, deletePropertyFiles)
require_once __DIR__ . '/helpers/upload.php';
