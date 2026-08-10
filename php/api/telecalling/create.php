<?php
/**
 * Create Telecalling Contact Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/telecalling/create.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();
$name   = trim($input['name']   ?? '');
$mobile = trim($input['mobile'] ?? '');
$city   = trim($input['city']   ?? '');
$notes  = trim($input['notes']  ?? '');

$errors = [];
if (empty($name)) {
    $errors['name'] = "Contact name is required.";
}

$cleanMobile = preg_replace('/[^\d]/', '', $mobile);
if (empty($mobile) || strlen($cleanMobile) < 10) {
    $errors['mobile'] = "Valid 10-digit mobile number is required.";
}

if (!empty($errors)) {
    sendJsonResponse(false, "Validation failed.", ['errors' => $errors], 422);
}

try {
    $db = Database::getConnection();

    // Auto-create telecalling_contacts table if missing
    $db->exec("
        CREATE TABLE IF NOT EXISTS telecalling_contacts (
            id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name        VARCHAR(255) NOT NULL,
            mobile      VARCHAR(20) NOT NULL,
            city        VARCHAR(100) NULL,
            notes       TEXT NULL,
            status      ENUM('pending', 'called', 'interested', 'not_interested', 'moved_to_inquiry') NOT NULL DEFAULT 'pending',
            created_by  INT NOT NULL,
            created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX       idx_status (status),
            INDEX       idx_mobile (mobile),
            INDEX       idx_created_by (created_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $stmt = $db->prepare("
        INSERT INTO telecalling_contacts (name, mobile, city, notes, status, created_by)
        VALUES (:name, :mobile, :city, :notes, 'pending', :created_by)
    ");
    $stmt->execute([
        ':name'       => $name,
        ':mobile'     => $cleanMobile,
        ':city'       => $city !== '' ? $city : null,
        ':notes'      => $notes !== '' ? $notes : null,
        ':created_by' => (int)($currentUser['id'] ?? $currentUser['user_id'] ?? 1),
    ]);

    $contactId = (int)$db->lastInsertId();

    sendJsonResponse(true, "Telecalling contact created successfully.", [
        'id'         => $contactId,
        'name'       => $name,
        'mobile'     => $cleanMobile,
        'city'       => $city,
        'notes'      => $notes,
        'status'     => 'pending',
        'created_at' => date('Y-m-d H:i:s'),
    ], 201);

} catch (Throwable $e) {
    error_log("Create telecalling contact error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to create telecalling contact: " . $e->getMessage(), null, 500);
}
