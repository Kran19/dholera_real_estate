<?php
/**
 * Property Details Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/properties/details.php?id=15
 */

require_once __DIR__ . '/../../middleware/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, "Method Not Allowed. Use GET.", null, 405);
}

if (empty($_GET['id'])) {
    sendJsonResponse(false, "Property ID is required.", null, 422);
}

$propertyId = (int)$_GET['id'];

try {
    $db = Database::getConnection();
    $baseUrl = getBaseUrl();

    $stmt = $db->prepare("
        SELECT p.*, u.username as creator_name 
        FROM properties p 
        LEFT JOIN users u ON u.id = p.created_by 
        WHERE p.id = :id
    ");
    $stmt->execute([':id' => $propertyId]);
    $prop = $stmt->fetch();

    if (!$prop) {
        sendJsonResponse(false, "Property not found.", null, 404);
    }

    $imgStmt = $db->prepare("SELECT id, image_url, sort_order FROM property_images WHERE property_id = :pid ORDER BY sort_order ASC");
    $imgStmt->execute([':pid' => $propertyId]);
    $rawImages = $imgStmt->fetchAll();

    $images = [];
    $primaryImage = null;

    foreach ($rawImages as $img) {
        if (preg_match('#^https?://#i', $img['image_url'])) {
            $fullUrl = $img['image_url'];
        } else {
            $cleanPath = preg_replace('#^php/#', '', ltrim($img['image_url'], '/'));
            $fullUrl = $baseUrl . '/' . $cleanPath;
        }

        $imgData = [
            "id"         => (int)$img['id'],
            "image_url"  => $fullUrl,
            "sort_order" => (int)$img['sort_order']
        ];
        $images[] = $imgData;
        if ($primaryImage === null || $img['sort_order'] === 1) {
            $primaryImage = $fullUrl;
        }
    }

    $prop['id'] = (int)$prop['id'];
    $prop['area'] = (float)$prop['area'];
    $prop['primary_image'] = $primaryImage;
    $prop['images'] = $images;

    if ($currentUser['role'] !== 'super_admin') {
        unset($prop['landing_price']);
    }

    sendJsonResponse(true, "Property details retrieved.", [
        "property" => $prop
    ]);

} catch (Exception $e) {
    error_log("Property details error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve property details: " . $e->getMessage(), null, 500);
}
