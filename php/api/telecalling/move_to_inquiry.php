<?php
/**
 * Move Telecalling Contact to Official Customer Inquiry Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/telecalling/move_to_inquiry.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input       = getJsonInput();
$contactId   = (int)($input['contact_id']   ?? 0);
$requirement = trim($input['requirement'] ?? '');
$notes       = trim($input['notes']       ?? '');

if ($contactId <= 0) {
    sendJsonResponse(false, "Invalid contact ID.", null, 422);
}
if (empty($requirement)) {
    sendJsonResponse(false, "Requirement is required when moving to Customer Inquiry.", ['errors' => ['requirement' => 'Requirement is required.']], 422);
}

try {
    $db = Database::getConnection();
    $currentUserId = (int)($currentUser['id'] ?? $currentUser['user_id'] ?? 1);

    // 1. Fetch contact
    $stmt = $db->prepare("SELECT id, name, mobile, city, notes FROM telecalling_contacts WHERE id = :id");
    $stmt->execute([':id' => $contactId]);
    $contact = $stmt->fetch();

    if (!$contact) {
        sendJsonResponse(false, "Telecalling contact not found.", null, 404);
    }

    $combinedNotes = trim(($contact['notes'] ? "Cold Call Note: {$contact['notes']}\n" : "") . ($notes ? "Inquiry Note: {$notes}" : ""));

    // 2. Ensure customer_inquiries table exists
    $db->exec("
        CREATE TABLE IF NOT EXISTS customer_inquiries (
            id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            customer_name VARCHAR(255) NOT NULL,
            mobile        VARCHAR(20)  NOT NULL,
            city          VARCHAR(100) NOT NULL,
            requirement   TEXT         NOT NULL,
            notes         TEXT         NULL,
            created_by    INT          NOT NULL,
            created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
            updated_at    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX         idx_mobile (mobile),
            INDEX         idx_created_by (created_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $db->beginTransaction();

    // 3. Create inquiry
    $inqStmt = $db->prepare("
        INSERT INTO customer_inquiries (customer_name, mobile, city, requirement, notes, created_by)
        VALUES (:name, :mobile, :city, :requirement, :notes, :created_by)
    ");
    $inqStmt->execute([
        ':name'        => $contact['name'],
        ':mobile'      => $contact['mobile'],
        ':city'        => $contact['city'] ?? '',
        ':requirement' => $requirement,
        ':notes'       => $combinedNotes !== '' ? $combinedNotes : null,
        ':created_by'  => $currentUserId,
    ]);
    $inquiryId = (int)$db->lastInsertId();

    // 4. Update contact status to moved_to_inquiry
    $updStmt = $db->prepare("UPDATE telecalling_contacts SET status = 'moved_to_inquiry' WHERE id = :id");
    $updStmt->execute([':id' => $contactId]);

    $db->commit();

    sendJsonResponse(true, "Contact successfully moved to Customer Inquiries!", [
        'inquiry_id' => $inquiryId,
        'contact_id' => $contactId,
        'name'       => $contact['name'],
        'mobile'     => $contact['mobile'],
    ], 201);

} catch (Throwable $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log("Move to inquiry error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to move contact to inquiry: " . $e->getMessage(), null, 500);
}
