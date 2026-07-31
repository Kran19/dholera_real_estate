<?php
/**
 * User Login Endpoint
 * DHOLERA REAL ESTATE
 * POST /api/auth/login.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

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

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("SELECT id, username, password_hash, role, status FROM users WHERE username = :username");
    $stmt->execute([':username' => $username]);
    $user = $stmt->fetch();

    if (!$user) {
        sendJsonResponse(false, "Invalid username or passcode.", null, 401);
    }

    if ($user['status'] !== 'active') {
        sendJsonResponse(false, "Account is deactivated. Please contact Super Admin.", null, 403);
    }

    if (!password_verify($password, $user['password_hash'])) {
        sendJsonResponse(false, "Invalid username or passcode.", null, 401);
    }

    // Create session token
    $token = createSessionToken((int)$user['id']);

    $userData = [
        "id"       => (int)$user['id'],
        "username" => $user['username'],
        "role"     => $user['role'],
        "status"   => $user['status']
    ];

    sendJsonResponse(true, "Login successful.", [
        "token" => $token,
        "user"  => $userData
    ]);

} catch (Exception $e) {
    error_log("Login error: " . $e->getMessage());
    sendJsonResponse(false, "An error occurred during login: " . $e->getMessage(), null, 500);
}
