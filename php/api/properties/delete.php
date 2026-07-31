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
        sendJsonResponse(false, "Property not found.", null, 404);
    }

    // 1. Clean physical filesystem directory and files
    deletePropertyFiles($propertyId);

    // 2. Delete property database record (Cascading foreign key deletes property_images)
    $delStmt = $db->prepare("DELETE FROM properties WHERE id = :id");
    $delStmt->execute([':id' => $propertyId]);

    sendJsonResponse(true, "Property '{$prop['village_name']} - Survey {$prop['survey_no']}' deleted successfully.", [
        "id" => $propertyId
    ]);

} catch (Exception $e) {
    error_log("Property deletion error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to delete property.", null, 500);
}
