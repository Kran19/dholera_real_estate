<?php
/**
 * Image Upload & File System Helper
 * DHOLERA REAL ESTATE
 */

require_once __DIR__ . '/../config/config.php';

/**
 * Validate Uploaded Image File Robustly
 */
function validateUploadedImage(array $file): ?string {
    if (!isset($file['error']) || $file['error'] !== UPLOAD_ERR_OK) {
        $errCode = $file['error'] ?? UPLOAD_ERR_NO_FILE;
        if ($errCode === UPLOAD_ERR_INI_SIZE || $errCode === UPLOAD_ERR_FORM_SIZE) {
            return "File size exceeds server upload limit.";
        }
        return "File upload failed with error code: " . $errCode;
    }

    if ($file['size'] > MAX_FILE_SIZE_BYTES) {
        return "File size exceeds maximum allowed limit of 5 MB.";
    }

    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($ext, ALLOWED_EXTENSIONS)) {
        return "Invalid file extension '.$ext'. Allowed: " . implode(', ', ALLOWED_EXTENSIONS);
    }

    // MIME type check with multiple robust fallbacks
    $mime = '';
    if (function_exists('finfo_open')) {
        $finfo = @finfo_open(FILEINFO_MIME_TYPE);
        if ($finfo) {
            $mime = @finfo_file($finfo, $file['tmp_name']);
            @finfo_close($finfo);
        }
    }

    if (empty($mime) && function_exists('getimagesize')) {
        $imgInfo = @getimagesize($file['tmp_name']);
        if ($imgInfo && isset($imgInfo['mime'])) {
            $mime = $imgInfo['mime'];
        }
    }

    if (empty($mime) && !empty($file['type'])) {
        $mime = strtolower($file['type']);
    }

    $allowedMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg', 'image/pjpeg', 'image/x-png', 'application/octet-stream'];
    if (!empty($mime) && !in_array($mime, $allowedMimes)) {
        return "Invalid image MIME type '$mime'.";
    }

    return null; // Valid
}

/**
 * Save Image File Safely with Permissive Directory Fallback
 */
function savePropertyImage(array $file, int $propertyId, int $sortOrder): string {
    $targetDir = UPLOAD_DIR . '/' . $propertyId;
    if (!file_exists($targetDir)) {
        @mkdir($targetDir, 0777, true);
        
        // Write .htaccess to disable PHP execution inside uploads
        $htaccessPath = UPLOAD_DIR . '/.htaccess';
        if (!file_exists($htaccessPath)) {
            @file_put_contents($htaccessPath, "<FilesMatch \"\.(php|phtml|exe|pl|cgi)$\">\n  Order Deny,Allow\n  Deny from all\n</FilesMatch>\nphp_flag engine off\n");
        }
    }

    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (empty($ext)) $ext = 'jpg';

    $randomHex = bin2hex(random_bytes(4));
    $newFilename = sprintf("img_%d_%d_%s.%s", $propertyId, time(), $randomHex, $ext);
    $targetPath = $targetDir . '/' . $newFilename;

    if (!@move_uploaded_file($file['tmp_name'], $targetPath)) {
        if (!@copy($file['tmp_name'], $targetPath)) {
            throw new Exception("Failed to save uploaded image to path '$targetPath'. Please check upload directory permissions.");
        }
    }

    // Relative web URL path stored in DB
    return "uploads/properties/" . $propertyId . "/" . $newFilename;
}

/**
 * Recursively Delete Property Upload Directory & Files
 */
function deletePropertyFiles(int $propertyId): void {
    $dir = UPLOAD_DIR . '/' . $propertyId;
    if (!is_dir($dir)) return;

    $files = array_diff(scandir($dir), ['.', '..']);
    foreach ($files as $file) {
        $filePath = $dir . '/' . $file;
        if (is_file($filePath)) {
            @unlink($filePath);
        }
    }
    @rmdir($dir);
}
