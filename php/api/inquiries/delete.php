<?php
/**
 * Delete Inquiry Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/inquiries/delete.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();
if (empty($input['id'])) {
    sendJsonResponse(false, "Inquiry ID is required.", null, 422);
}

$inquiryId = (int)$input['id'];

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("SELECT id, customer_name FROM inquiries WHERE id = :id");
    $stmt->execute([':id' => $inquiryId]);
    $inquiry = $stmt->fetch();

    if (!$inquiry) {
        sendJsonResponse(false, "Inquiry not found.", null, 404);
    }

    $deleteStmt = $db->prepare("DELETE FROM inquiries WHERE id = :id");
    $deleteStmt->execute([':id' => $inquiryId]);

    sendJsonResponse(true, "Inquiry for '{$inquiry['customer_name']}' deleted successfully.", [
        "id" => $inquiryId
    ]);

} catch (Exception $e) {
    error_log("Inquiry deletion error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to delete inquiry: " . $e->getMessage(), null, 500);
}
