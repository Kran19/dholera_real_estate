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

$latestVersion = '1.0.7';
$versionFile = __DIR__ . '/api/config/version.php';
if (file_exists($versionFile)) {
    $content = file_get_contents($versionFile);
    if (preg_match('/"latest_version"\s*=>\s*"([^"]+)"/', $content, $matches)) {
        $latestVersion = $matches[1];
    }
}

$fileSize = filesize($apkPath);

// Clear output buffers to prevent corruption
if (ob_get_level()) {
    ob_end_clean();
}

header('Content-Description: File Transfer');
header('Content-Type: application/vnd.android.package-archive');
header('Content-Disposition: attachment; filename="DholeraRealEstate-v' . $latestVersion . '.apk"');
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
