<?php
/**
 * Today's Telecalling Rotating Batch Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * GET /api/telecalling/today.php?date=2026-08-10
 *
 * Implements 10-Day Equal Distribution Logic:
 *   N            = Total active telecalling contacts (status != 'moved_to_inquiry')
 *   cycleLength  = 10 Days
 *   dailyTarget  = ceil(N / 10)
 *   dayIndex     = daysSince(2026-01-01) % 10
 *   startIndex   = (dayIndex * dailyTarget) % max(1, N)
 *   todayBatch   = slice of dailyTarget items with circular wrap
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, "Method Not Allowed. Use GET.", null, 405);
}

$date = trim($_GET['date'] ?? date('Y-m-d'));
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
    sendJsonResponse(false, "Invalid date format. Use yyyy-mm-dd.", null, 422);
}

try {
    $db = Database::getConnection();

    // Ensure tables exist
    $db->exec("
        CREATE TABLE IF NOT EXISTS telecalling_contacts (
            id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name        VARCHAR(255) NOT NULL,
            mobile      VARCHAR(20) NOT NULL,
            city        VARCHAR(100) NULL,
            notes       TEXT NULL,
            status      ENUM('pending', 'called', 'interested', 'not_interested', 'moved_to_inquiry') NOT NULL DEFAULT 'pending',
            created_by  INT NOT NULL,
            created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX       idx_status (status),
            INDEX       idx_mobile (mobile),
            INDEX       idx_created_by (created_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $db->exec("
        CREATE TABLE IF NOT EXISTS telecalling_call_logs (
            id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            contact_id  INT NOT NULL,
            called_date DATE NOT NULL,
            status      ENUM('received','pending','no_answer','callback','not_interested','confirmed') NOT NULL DEFAULT 'pending',
            remarks     TEXT NULL,
            created_by  INT NOT NULL,
            created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY  uq_contact_date_user (contact_id, called_date, created_by),
            INDEX       idx_called_date (called_date),
            INDEX       idx_contact_id (contact_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    // 1. Fetch all active telecalling contacts ordered by id ASC
    $stmt = $db->prepare("
        SELECT id, name, mobile, city, notes, status, created_at
        FROM telecalling_contacts
        WHERE status != 'moved_to_inquiry'
        ORDER BY id ASC
    ");
    $stmt->execute();
    $allContacts = $stmt->fetchAll();

    $N = count($allContacts);
    $cycleLength = 10;
    $dailyTarget = $N > 0 ? (int)ceil($N / $cycleLength) : 0;

    // Days since fixed epoch (2026-01-01)
    $epochTimestamp  = strtotime('2026-01-01');
    $targetTimestamp = strtotime($date);
    $daysSinceEpoch  = max(0, (int)floor(($targetTimestamp - $epochTimestamp) / 86400));
    $dayIndex        = $daysSinceEpoch % $cycleLength;

    $todayBatch = [];
    if ($N > 0 && $dailyTarget > 0) {
        $startIndex = ($dayIndex * $dailyTarget) % $N;
        for ($i = 0; $i < $dailyTarget; $i++) {
            $idx = ($startIndex + $i) % $N;
            $contact = $allContacts[$idx];
            $contact['id'] = (int)$contact['id'];
            $contact['city'] = $contact['city'] ?? '';
            $contact['notes'] = $contact['notes'] ?? '';
            $todayBatch[] = $contact;
        }
    }

    // 2. Fetch call logs for $date
    $currentUserId = (int)($currentUser['id'] ?? $currentUser['user_id'] ?? 1);
    $logStmt = $db->prepare("
        SELECT contact_id, called_date, status, remarks, updated_at
        FROM telecalling_call_logs
        WHERE called_date = :date
          AND created_by  = :user_id
        ORDER BY updated_at DESC
    ");
    $logStmt->execute([
        ':date'    => $date,
        ':user_id' => $currentUserId,
    ]);
    $logs = $logStmt->fetchAll();

    foreach ($logs as &$log) {
        $log['contact_id'] = (int)$log['contact_id'];
        $log['remarks']    = $log['remarks'] ?? '';
    }
    unset($log);

    sendJsonResponse(true, "Today's telecalling batch retrieved successfully.", [
        'date'           => $date,
        'day_index'      => $dayIndex,
        'cycle_length'   => $cycleLength,
        'total_contacts' => $N,
        'daily_target'   => $dailyTarget,
        'today_batch'    => $todayBatch,
        'logs'           => $logs,
    ]);

} catch (Throwable $e) {
    error_log("Telecalling today error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve telecalling batch: " . $e->getMessage(), null, 500);
}
