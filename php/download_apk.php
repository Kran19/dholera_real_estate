<?php
/**
 * Direct Binary APK File Downloader Endpoint
 * DHOLERA REAL ESTATE — Serves 100% complete APK without truncation
 */

$apkPath = __DIR__ . '/app-release.apk';

if (!file_exists($apkPath)) {
    http_response_code(404);
    die("APK file not found on server.");
}

$fileSize = filesize($apkPath);

// Clear output buffers to prevent corruption
if (ob_get_level()) {
    ob_end_clean();
}

header('Content-Description: File Transfer');
header('Content-Type: application/vnd.android.package-archive');
header('Content-Disposition: attachment; filename="DholeraRealEstate-v1.0.4.apk"');
header('Content-Transfer-Encoding: binary');
header('Expires: 0');
header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
header('Pragma: public');
header('Content-Length: ' . $fileSize);

// Read file in 8KB chunks for memory efficiency and smooth transfer
$handle = fopen($apkPath, 'rb');
if ($handle !== false) {
    while (!feof($handle)) {
        echo fread($handle, 8192);
        flush();
    }
    fclose($handle);
}
exit();
