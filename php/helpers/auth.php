<?php
/**
 * Authentication Helpers
 * DHOLERA REAL ESTATE
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/config.php';

/**
 * Generate Secure Hexadecimal Bearer Token
 */
function generateBearerToken(): string {
    return bin2hex(random_bytes(32)); // 64-character secure token
}

/**
 * Store Bearer Token in DB
 */
function createSessionToken(int $userId): string {
    $db = Database::getConnection();
    $token = generateBearerToken();
    $expiresAt = date('Y-m-d H:i:s', time() + TOKEN_EXPIRY_SECONDS);

    $stmt = $db->prepare("INSERT INTO user_tokens (user_id, token, expires_at) VALUES (:user_id, :token, :expires_at)");
    $stmt->execute([
        ':user_id'    => $userId,
        ':token'      => $token,
        ':expires_at' => $expiresAt
    ]);

    return $token;
}

/**
 * Validate Bearer Token from HTTP Headers
 */
function validateToken(string $token): ?array {
    $db = Database::getConnection();

    $stmt = $db->prepare("
        SELECT u.id, u.username, u.role, u.status, t.expires_at 
        FROM user_tokens t
        JOIN users u ON u.id = t.user_id
        WHERE t.token = :token AND t.expires_at > NOW()
    ");
    $stmt->execute([':token' => $token]);
    $user = $stmt->fetch();

    if (!$user || $user['status'] !== 'active') {
        return null;
    }

    return $user;
}

/**
 * Revoke/Delete Session Token
 */
function revokeToken(string $token): bool {
    $db = Database::getConnection();
    $stmt = $db->prepare("DELETE FROM user_tokens WHERE token = :token");
    return $stmt->execute([':token' => $token]);
}
