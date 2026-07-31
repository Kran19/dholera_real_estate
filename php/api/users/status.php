<?php
/**
 * Toggle User Active/Inactive Status (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/users/status.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';
require_once __DIR__ . '/../../helpers/validation.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();
if (empty($input['id']) || empty($input['status'])) {
    sendJsonResponse(false, "User ID and status are required.", null, 422);
}

$userId = (int)$input['id'];
$newStatus = strtolower(trim($input['status']));

if (!in_array($newStatus, ['active', 'inactive'])) {
    sendJsonResponse(false, "Invalid status value. Must be 'active' or 'inactive'.", null, 422);
}

if ($userId === (int)$currentUser['id']) {
    sendJsonResponse(false, "Super Admin cannot deactivate their own account.", null, 400);
}

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("UPDATE users SET status = :status WHERE id = :id");
    $stmt->execute([':status' => $newStatus, ':id' => $userId]);

    // If deactivated, invalidate all active tokens for this user
    if ($newStatus === 'inactive') {
        $revokeStmt = $db->prepare("DELETE FROM user_tokens WHERE user_id = :user_id");
        $revokeStmt->execute([':user_id' => $userId]);
    }

    sendJsonResponse(true, "User status updated to '$newStatus'.", [
        "id"     => $userId,
        "status" => $newStatus
    ]);

} catch (Exception $e) {
    error_log("User status update error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to update user status: " . $e->getMessage(), null, 500);
}
