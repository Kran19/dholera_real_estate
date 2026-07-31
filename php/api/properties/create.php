<?php
/**
 * Create Property Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/properties/create.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';
require_once __DIR__ . '/../../helpers/validation.php';
require_once __DIR__ . '/../../helpers/upload.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

// Multipart or JSON input handling
$input = !empty($_POST) ? $_POST : getJsonInput();

$errors = validateRequired($input, ['village_name', 'survey_no', 'zone', 'road', 'area', 'area_unit']);
if (!empty($errors)) {
    sendJsonResponse(false, "Validation failed.", null, 422, null, $errors);
}

$villageName = sanitizeString($input['village_name']);
$surveyNo    = sanitizeString($input['survey_no']);
$zone        = sanitizeString($input['zone']);
$tp          = sanitizeString($input['tp'] ?? '');
$fp          = sanitizeString($input['fp'] ?? '');
$road        = sanitizeString($input['road']);
$area        = (float)$input['area'];
$areaUnit    = sanitizeString($input['area_unit']);
$reference   = sanitizeString($input['reference'] ?? '');

if ($area <= 0) {
    sendJsonResponse(false, "Area must be a positive numeric value.", null, 422);
}

// Check attached files
$uploadedFiles = [];
if (!empty($_FILES['images']) && is_array($_FILES['images']['name'])) {
    $fileCount = count($_FILES['images']['name']);
    if ($fileCount > MAX_PROPERTY_IMAGES) {
        sendJsonResponse(false, "Maximum " . MAX_PROPERTY_IMAGES . " photos allowed per property.", null, 400);
    }

    for ($i = 0; $i < $fileCount; $i++) {
        if (!empty($_FILES['images']['name'][$i])) {
            $file = [
                'name'     => $_FILES['images']['name'][$i],
                'type'     => $_FILES['images']['type'][$i],
                'tmp_name' => $_FILES['images']['tmp_name'][$i],
                'error'    => $_FILES['images']['error'][$i],
                'size'     => $_FILES['images']['size'][$i]
            ];

            $valError = validateUploadedImage($file);
            if ($valError !== null) {
                sendJsonResponse(false, "Image #".($i+1)." validation error: " . $valError, null, 400);
            }
            $uploadedFiles[] = $file;
        }
    }
}

try {
    $db = Database::getConnection();
    $db->beginTransaction();

    $stmt = $db->prepare("
        INSERT INTO properties (village_name, survey_no, zone, tp, fp, road, area, area_unit, reference, created_by)
        VALUES (:village_name, :survey_no, :zone, :tp, :fp, :road, :area, :area_unit, :reference, :created_by)
    ");

    $stmt->execute([
        ':village_name' => $villageName,
        ':survey_no'    => $surveyNo,
        ':zone'          => $zone,
        ':tp'            => $tp,
        ':fp'            => $fp,
        ':road'          => $road,
        ':area'          => $area,
        ':area_unit'     => $areaUnit,
        ':reference'     => $reference,
        ':created_by'    => $currentUser['id']
    ]);

    $propertyId = (int)$db->lastInsertId();

    // Process & Save Image Files
    $savedImages = [];
    $sortOrder = 1;
    $imgInsertStmt = $db->prepare("INSERT INTO property_images (property_id, image_url, sort_order) VALUES (:pid, :url, :sort)");

    foreach ($uploadedFiles as $file) {
        $relativePath = savePropertyImage($file, $propertyId, $sortOrder);
        $imgInsertStmt->execute([
            ':pid'  => $propertyId,
            ':url'  => $relativePath,
            ':sort' => $sortOrder
        ]);
        $savedImages[] = [
            "id"         => (int)$db->lastInsertId(),
            "image_url"  => getBaseUrl() . '/' . $relativePath,
            "sort_order" => $sortOrder
        ];
        $sortOrder++;
    }

    $db->commit();

    sendJsonResponse(true, "Property created successfully.", [
        "property" => [
            "id"           => $propertyId,
            "village_name" => $villageName,
            "survey_no"    => $surveyNo,
            "zone"         => $zone,
            "tp"           => $tp,
            "fp"           => $fp,
            "road"         => $road,
            "area"         => $area,
            "area_unit"    => $areaUnit,
            "reference"    => $reference,
            "images"       => $savedImages
        ]
    ], 201);

} catch (Exception $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log("Property creation error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to create property.", null, 500);
}
