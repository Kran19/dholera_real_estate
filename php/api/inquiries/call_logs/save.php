<?php
/**
 * Save Call Log Endpoint (Super Admin Only) — Upsert
 * DHOLERA REAL ESTATE
 * POST /api/inquiries/call_logs/save.php
 *
 * Saves or updates a call log for a given inquiry on a given date.
 * One log per (inquiry_id + called_date + created_by) — upsert via
 * INSERT ... ON DUPLICATE KEY UPDATE.
 */

require_once __DIR__ . '/../../../middleware/auth.php';
require_once __DIR__ . '/../../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input  = getJsonInput();
$errors = validateRequired($input, ['inquiry_id', 'called_date', 'status']);

if (!empty($errors)) {
    sendJsonResponse(false, "Validation failed.", null, 422, null, $errors);
}

$allowedStatuses = ['received', 'pending', 'no_answer', 'callback', 'not_interested'];
if (!in_array($input['status'], $allowedStatuses, true)) {
    sendJsonResponse(false, "Invalid status value. Allowed: " . implode(', ', $allowedStatuses), null, 422);
}

// Validate date format yyyy-mm-dd
$calledDate = trim($input['called_date']);
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $calledDate)) {
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

    $inquiryId = (int)$input['inquiry_id'];
    $status    = $input['status'];
    $remarks   = trim($input['remarks'] ?? '');
    $createdBy = (int)($currentUser['id'] ?? $currentUser['user_id'] ?? 1);

    $stmt = $db->prepare("
        INSERT INTO inquiry_call_logs (inquiry_id, called_date, status, remarks, created_by)
        VALUES (:inquiry_id, :called_date, :status, :remarks, :created_by)
        ON DUPLICATE KEY UPDATE
            status     = VALUES(status),
            remarks    = VALUES(remarks),
            updated_at = CURRENT_TIMESTAMP
    ");
    $stmt->execute([
        ':inquiry_id'  => $inquiryId,
        ':called_date' => $calledDate,
        ':status'      => $status,
        ':remarks'     => $remarks,
        ':created_by'  => $createdBy,
    ]);

    sendJsonResponse(true, "Call log saved successfully.", [
        'inquiry_id'  => $inquiryId,
        'called_date' => $calledDate,
        'status'      => $status,
        'remarks'     => $remarks,
    ]);

} catch (Throwable $e) {
    error_log("Call log save error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to save call log: " . $e->getMessage(), null, 500);
}
