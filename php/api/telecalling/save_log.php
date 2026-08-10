<?php
/**
 * Save Telecalling Call Log Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/telecalling/save_log.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input      = getJsonInput();
$contactId  = (int)($input['contact_id']  ?? 0);
$calledDate = trim($input['called_date'] ?? date('Y-m-d'));
$status     = trim($input['status']      ?? 'pending');
$remarks    = trim($input['remarks']     ?? '');

$validStatuses = ['received','pending','no_answer','callback','not_interested','confirmed'];

if ($contactId <= 0) {
    sendJsonResponse(false, "Invalid contact ID.", null, 422);
}
if (!in_array($status, $validStatuses, true)) {
    sendJsonResponse(false, "Invalid status value.", null, 422);
}
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $calledDate)) {
    sendJsonResponse(false, "Invalid called_date format. Use yyyy-mm-dd.", null, 422);
}

try {
    $db = Database::getConnection();
    $currentUserId = (int)($currentUser['id'] ?? $currentUser['user_id'] ?? 1);

    // Upsert call log
    $stmt = $db->prepare("
        INSERT INTO telecalling_call_logs (contact_id, called_date, status, remarks, created_by)
        VALUES (:contact_id, :called_date, :status, :remarks, :created_by)
        ON DUPLICATE KEY UPDATE
            status     = VALUES(status),
            remarks    = VALUES(remarks),
            updated_at = CURRENT_TIMESTAMP
    ");
    $stmt->execute([
        ':contact_id'  => $contactId,
        ':called_date' => $calledDate,
        ':status'      => $status,
        ':remarks'     => $remarks !== '' ? $remarks : null,
        ':created_by'  => $currentUserId,
    ]);

    // Also update contact status in telecalling_contacts if status is called/interested/not_interested
    if (in_array($status, ['received', 'no_answer', 'callback', 'not_interested', 'confirmed'], true)) {
        $contactStatus = $status === 'confirmed' ? 'interested' : ($status === 'not_interested' ? 'not_interested' : 'called');
        $upd = $db->prepare("UPDATE telecalling_contacts SET status = :cstatus WHERE id = :cid AND status != 'moved_to_inquiry'");
        $upd->execute([':cstatus' => $contactStatus, ':cid' => $contactId]);
    }

    sendJsonResponse(true, "Call log saved successfully.", [
        'contact_id'  => $contactId,
        'called_date' => $calledDate,
        'status'      => $status,
        'remarks'     => $remarks,
        'updated_at'  => date('Y-m-d H:i:s'),
    ]);

} catch (Throwable $e) {
    error_log("Save telecalling log error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to save call log: " . $e->getMessage(), null, 500);
}
