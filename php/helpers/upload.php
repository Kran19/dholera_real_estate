<?php
/**
 * Image Upload & File System Helper
 * DHOLERA REAL ESTATE
 */

require_once __DIR__ . '/../config/config.php';

/**
 * Validate Uploaded Image File
 */
function validateUploadedImage(array $file): ?string {
    if ($file['error'] !== UPLOAD_ERR_OK) {
        return "File upload error code: " . $file['error'];
    }

    if ($file['size'] > MAX_FILE_SIZE_BYTES) {
        return "File size exceeds maximum allowed limit of 5 MB.";
    }

    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($ext, ALLOWED_EXTENSIONS)) {
        return "Invalid file extension '.$ext'. Allowed: " . implode(', ', ALLOWED_EXTENSIONS);
    }

    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mime, ALLOWED_MIME_TYPES)) {
        return "Invalid image MIME type '$mime'.";
    }

    return null; // Valid
}

/**
 * Save Image File Safely
 */
function savePropertyImage(array $file, int $propertyId, int $sortOrder): string {
    $targetDir = UPLOAD_DIR . '/' . $propertyId;
    if (!file_exists($targetDir)) {
        mkdir($targetDir, 0755, true);
        
        // Write .htaccess to disable PHP execution inside uploads
        $htaccessPath = UPLOAD_DIR . '/.htaccess';
        if (!file_exists($htaccessPath)) {
            file_put_contents($htaccessPath, "<FilesMatch \"\.(php|phtml|exe|pl|cgi)$\">\n  Order Deny,Allow\n  Deny from all\n</FilesMatch>\nphp_flag engine off\n");
        }
    }

    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    $randomHex = bin2hex(random_bytes(4));
    $newFilename = sprintf("img_%d_%d_%s.%s", $propertyId, time(), $randomHex, $ext);
    $targetPath = $targetDir . '/' . $newFilename;

    if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
        throw new Exception("Failed to save uploaded file to destination server path.");
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
