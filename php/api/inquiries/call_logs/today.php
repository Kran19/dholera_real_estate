<?php
/**
 * Today's Call Logs Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * GET /api/inquiries/call_logs/today.php?date=2026-08-09
 *
 * Returns all call logs saved by the authenticated admin for the given date.
 */

require_once __DIR__ . '/../../../middleware/auth.php';
require_once __DIR__ . '/../../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, "Method Not Allowed. Use GET.", null, 405);
}

$date = trim($_GET['date'] ?? date('Y-m-d'));
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
    sendJsonResponse(false, "Invalid date format. Use yyyy-mm-dd.", null, 422);
}

try {
    $db = Database::getConnection();

    // Auto-create call_logs table if missing
    $db->exec("
        CREATE TABLE IF NOT EXISTS inquiry_call_logs (
            id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            inquiry_id  INT NOT NULL,
            called_date DATE NOT NULL,
            status      ENUM('received','pending','no_answer','callback','not_interested') NOT NULL DEFAULT 'pending',
            remarks     TEXT NULL,
            created_by  INT NOT NULL,
            created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY  uq_inquiry_date_user (inquiry_id, called_date, created_by),
            INDEX       idx_called_date (called_date),
            INDEX       idx_inquiry_id (inquiry_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $stmt = $db->prepare("
        SELECT inquiry_id, called_date, status, remarks, updated_at
        FROM inquiry_call_logs
        WHERE called_date = :date
          AND created_by  = :user_id
        ORDER BY updated_at DESC
    ");
    $stmt->execute([
        ':date'    => $date,
        ':user_id' => (int)($currentUser['id'] ?? $currentUser['user_id'] ?? 1),
    ]);
    $logs = $stmt->fetchAll();

    foreach ($logs as &$log) {
        $log['inquiry_id'] = (int)$log['inquiry_id'];
        $log['remarks']    = $log['remarks'] ?? '';
    }
    unset($log);

    sendJsonResponse(true, "Call logs retrieved successfully.", [
        'date' => $date,
        'logs' => $logs,
    ]);

} catch (Throwable $e) {
    error_log("Call log today error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve call logs: " . $e->getMessage(), null, 500);
}
