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
$rawMobile      = sanitizeString($input['customer_mobile']);
$requirement    = sanitizeString($input['requirement'] ?? '');
$notes          = sanitizeString($input['notes'] ?? '');

if (strlen($customerName) < 2) {
    sendJsonResponse(false, "Customer name must be at least 2 characters.", null, 422);
}

// Clean and format mobile number with +91 prefix
$digits = preg_replace('/[^\d]/', '', $rawMobile);
if (strpos($digits, '91') === 0 && strlen($digits) === 12) {
    $digits = substr($digits, 2);
}

if (strlen($digits) !== 10) {
    sendJsonResponse(false, "Mobile number must be exactly 10 digits.", null, 422);
}

$customerMobile = '+91 ' . $digits;

try {
    $db = Database::getConnection();

    // Auto-create inquiries table safely if missing
    $db->exec("
        CREATE TABLE IF NOT EXISTS inquiries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_name VARCHAR(100) NOT NULL,
            customer_city VARCHAR(100) NOT NULL,
            customer_mobile VARCHAR(20) NOT NULL,
            requirement TEXT NULL,
            notes TEXT NULL,
            created_by INT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_inquiries_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    // Self-healing: Ensure requirement column exists on live DB instances
    $cols = $db->query("SHOW COLUMNS FROM inquiries LIKE 'requirement'")->fetch();
    if (!$cols) {
        $db->exec("ALTER TABLE inquiries ADD COLUMN requirement TEXT NULL AFTER customer_mobile;");
    }

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
        ':created_by'  => $currentUser['id'] ?? 1
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

} catch (Throwable $e) {
    error_log("Inquiry creation error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to record inquiry: " . $e->getMessage(), null, 500);
}
