<?php
/**
 * Delete Telecalling Contact Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/telecalling/delete.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input     = getJsonInput();
$contactId = (int)($input['contact_id'] ?? 0);

if ($contactId <= 0) {
    sendJsonResponse(false, "Invalid contact ID.", null, 422);
}

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("DELETE FROM telecalling_contacts WHERE id = :id");
    $stmt->execute([':id' => $contactId]);

    // Also clean logs
    $logStmt = $db->prepare("DELETE FROM telecalling_call_logs WHERE contact_id = :id");
    $logStmt->execute([':id' => $contactId]);

    sendJsonResponse(true, "Telecalling contact deleted successfully.", ['contact_id' => $contactId]);

} catch (Throwable $e) {
    error_log("Delete telecalling contact error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to delete telecalling contact: " . $e->getMessage(), null, 500);
}
