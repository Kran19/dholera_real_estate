<?php
/**
 * Create User Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/users/create.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';
require_once __DIR__ . '/../../helpers/validation.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();
$errors = validateRequired($input, ['username', 'password']);

if (!empty($errors)) {
    sendJsonResponse(false, "Validation failed.", null, 422, null, $errors);
}

$username = sanitizeString($input['username']);
$password = $input['password'];
$status = in_array($input['status'] ?? 'active', ['active', 'inactive']) ? $input['status'] : 'active';
$role = 'user'; // Newly created users are assigned role 'user'

if (strlen($username) < 3 || strlen($username) > 50) {
    sendJsonResponse(false, "Username must be between 3 and 50 characters.", null, 422);
}

if (strlen($password) < 4) {
    sendJsonResponse(false, "Passcode must be at least 4 characters long.", null, 422);
}

try {
    $db = Database::getConnection();

    // Check duplicate
    $checkStmt = $db->prepare("SELECT id FROM users WHERE username = :username");
    $checkStmt->execute([':username' => $username]);
    if ($checkStmt->fetch()) {
        sendJsonResponse(false, "Username '$username' is already taken.", null, 400);
    }

    $hash = password_hash($password, PASSWORD_DEFAULT);

    $stmt = $db->prepare("INSERT INTO users (username, password_hash, role, status) VALUES (:username, :hash, :role, :status)");
    $stmt->execute([
        ':username' => $username,
        ':hash'     => $hash,
        ':role'     => $role,
        ':status'   => $status
    ]);

    $newId = (int)$db->lastInsertId();

    sendJsonResponse(true, "User '$username' created successfully.", [
        "user" => [
            "id"       => $newId,
            "username" => $username,
            "role"     => $role,
            "status"   => $status
        ]
    ], 201);

} catch (Exception $e) {
    error_log("User creation error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to create user account: " . $e->getMessage(), null, 500);
}
