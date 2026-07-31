<?php
/**
 * Edit User Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/users/update.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';
require_once __DIR__ . '/../../helpers/validation.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();
if (empty($input['id'])) {
    sendJsonResponse(false, "User ID is required.", null, 422);
}

$userId = (int)$input['id'];

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("SELECT id, username, role, status FROM users WHERE id = :id");
    $stmt->execute([':id' => $userId]);
    $user = $stmt->fetch();

    if (!$user) {
        sendJsonResponse(false, "User not found.", null, 404);
    }

    $updates = [];
    $params = [':id' => $userId];

    if (!empty($input['username'])) {
        $newUsername = sanitizeString($input['username']);
        if ($newUsername !== $user['username']) {
            $dupCheck = $db->prepare("SELECT id FROM users WHERE username = :username AND id != :id");
            $dupCheck->execute([':username' => $newUsername, ':id' => $userId]);
            if ($dupCheck->fetch()) {
                sendJsonResponse(false, "Username '$newUsername' is already taken.", null, 400);
            }
            $updates[] = "username = :username";
            $params[':username'] = $newUsername;
        }
    }

    if (!empty($input['password'])) {
        $newPassword = $input['password'];
        if (strlen($newPassword) < 4) {
            sendJsonResponse(false, "Passcode must be at least 4 characters long.", null, 422);
        }
        $updates[] = "password_hash = :hash";
        $params[':hash'] = password_hash($newPassword, PASSWORD_DEFAULT);
    }

    if (!empty($input['status']) && in_array($input['status'], ['active', 'inactive'])) {
        $updates[] = "status = :status";
        $params[':status'] = $input['status'];
    }

    if (empty($updates)) {
        sendJsonResponse(true, "No changes were made.", ["user" => $user]);
    }

    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = :id";
    $updateStmt = $db->prepare($sql);
    $updateStmt->execute($params);

    // Fetch updated
    $stmt->execute([':id' => $userId]);
    $updatedUser = $stmt->fetch();

    sendJsonResponse(true, "User updated successfully.", ["user" => $updatedUser]);

} catch (Exception $e) {
    error_log("User update error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to update user.", null, 500);
}
