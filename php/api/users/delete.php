<?php
/**
 * Delete User Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/users/delete.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();
if (empty($input['id'])) {
    sendJsonResponse(false, "User ID is required.", null, 422);
}

$userId = (int)$input['id'];

if ($userId === (int)$currentUser['id']) {
    sendJsonResponse(false, "Super Admin cannot delete their own account.", null, 400);
}

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("SELECT id, username, role FROM users WHERE id = :id");
    $stmt->execute([':id' => $userId]);
    $user = $stmt->fetch();

    if (!$user) {
        sendJsonResponse(false, "User not found.", null, 404);
    }

    $deleteStmt = $db->prepare("DELETE FROM users WHERE id = :id");
    $deleteStmt->execute([':id' => $userId]);

    sendJsonResponse(true, "User '{$user['username']}' deleted successfully.", [
        "id" => $userId
    ]);

} catch (Exception $e) {
    error_log("User deletion error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to delete user.", null, 500);
}
