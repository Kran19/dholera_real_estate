<?php
/**
 * Delete Property Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/properties/delete.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';
require_once __DIR__ . '/../../helpers/upload.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = getJsonInput();

if (empty($input['id'])) {
    sendJsonResponse(false, "Property ID is required.", null, 422);
}

$propertyId = (int)$input['id'];

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("SELECT id, village_name, survey_no FROM properties WHERE id = :id");
    $stmt->execute([':id' => $propertyId]);
    $prop = $stmt->fetch();

    if (!$prop) {
        sendJsonResponse(false, "Property not found or already deleted.", null, 404);
    }

    // 1. Explicitly delete child image records from property_images table
    $imgStmt = $db->prepare("DELETE FROM property_images WHERE property_id = :id");
    $imgStmt->execute([':id' => $propertyId]);

    // 2. Clean physical filesystem directory and files safely
    try {
        deletePropertyFiles($propertyId);
    } catch (Throwable $fe) {
        error_log("File deletion warning for property $propertyId: " . $fe->getMessage());
    }

    // 3. Delete main property database record
    $delStmt = $db->prepare("DELETE FROM properties WHERE id = :id");
    $delStmt->execute([':id' => $propertyId]);

    sendJsonResponse(true, "Property '{$prop['village_name']} - Survey {$prop['survey_no']}' deleted successfully.", [
        "id" => $propertyId
    ]);

} catch (Exception $e) {
    error_log("Property deletion error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to delete property: " . $e->getMessage(), null, 500);
}
