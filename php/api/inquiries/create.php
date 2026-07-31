<?php
/**
 * Create Inquiry Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/inquiries/create.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();
$errors = validateRequired($input, ['customer_name', 'customer_city', 'customer_mobile']);

if (!empty($errors)) {
    sendJsonResponse(false, "Validation failed.", null, 422, null, $errors);
}

$customerName   = sanitizeString($input['customer_name']);
$customerCity   = sanitizeString($input['customer_city']);
$customerMobile = sanitizeString($input['customer_mobile']);
$requirement    = sanitizeString($input['requirement'] ?? '');
$notes          = sanitizeString($input['notes'] ?? '');

if (strlen($customerName) < 2) {
    sendJsonResponse(false, "Customer name must be at least 2 characters.", null, 422);
}

if (strlen($customerMobile) < 7 || strlen($customerMobile) > 20) {
    sendJsonResponse(false, "Please enter a valid mobile number.", null, 422);
}

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("
        INSERT INTO inquiries (customer_name, customer_city, customer_mobile, requirement, notes, created_by)
        VALUES (:name, :city, :mobile, :requirement, :notes, :created_by)
    ");

    $stmt->execute([
        ':name'        => $customerName,
        ':city'        => $customerCity,
        ':mobile'      => $customerMobile,
        ':requirement' => $requirement,
        ':notes'       => $notes,
        ':created_by'  => $currentUser['id']
    ]);

    $newId = (int)$db->lastInsertId();

    sendJsonResponse(true, "Inquiry recorded successfully.", [
        "inquiry" => [
            "id"              => $newId,
            "customer_name"   => $customerName,
            "customer_city"   => $customerCity,
            "customer_mobile" => $customerMobile,
            "requirement"     => $requirement,
            "notes"           => $notes,
            "created_at"      => date('Y-m-d H:i:s')
        ]
    ], 201);

} catch (Exception $e) {
    error_log("Inquiry creation error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to record inquiry: " . $e->getMessage(), null, 500);
}
