<?php
/**
 * Update Property Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * POST /api/properties/update.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';
require_once __DIR__ . '/../../helpers/validation.php';
require_once __DIR__ . '/../../helpers/upload.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, "Method Not Allowed. Use POST.", null, 405);
}

$input = !empty($_POST) ? $_POST : getJsonInput();

if (empty($input['id'])) {
    sendJsonResponse(false, "Property ID is required.", null, 422);
}

$propertyId = (int)$input['id'];

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("SELECT id FROM properties WHERE id = :id");
    $stmt->execute([':id' => $propertyId]);
    if (!$stmt->fetch()) {
        sendJsonResponse(false, "Property not found.", null, 404);
    }

    $villageName = sanitizeString($input['village_name'] ?? '');
    $surveyNo    = sanitizeString($input['survey_no'] ?? '');
    $zone        = sanitizeString($input['zone'] ?? '');
    $tp          = sanitizeString($input['tp'] ?? '');
    $fp          = sanitizeString($input['fp'] ?? '');
    $road        = sanitizeString($input['road'] ?? '');
    $area        = isset($input['area']) ? (float)$input['area'] : null;
    $areaUnit    = sanitizeString($input['area_unit'] ?? '');
    $reference   = sanitizeString($input['reference'] ?? '');

    $updates = [];
    $params = [':id' => $propertyId];

    if ($villageName !== '') { $updates[] = "village_name = :v"; $params[':v'] = $villageName; }
    if ($surveyNo !== '')    { $updates[] = "survey_no = :s";    $params[':s'] = $surveyNo; }
    if ($zone !== '')        { $updates[] = "zone = :z";         $params[':z'] = $zone; }
    if (isset($input['tp'])) { $updates[] = "tp = :tp";          $params[':tp'] = $tp; }
    if (isset($input['fp'])) { $updates[] = "fp = :fp";          $params[':fp'] = $fp; }
    if ($road !== '')        { $updates[] = "road = :r";         $params[':r'] = $road; }
    if ($area !== null && $area > 0) { $updates[] = "area = :a"; $params[':a'] = $area; }
    if ($areaUnit !== '')    { $updates[] = "area_unit = :au";   $params[':au'] = $areaUnit; }
    if (isset($input['reference'])) { $updates[] = "reference = :ref"; $params[':ref'] = $reference; }

    if (!empty($updates)) {
        $sql = "UPDATE properties SET " . implode(', ', $updates) . " WHERE id = :id";
        $upStmt = $db->prepare($sql);
        $upStmt->execute($params);
    }

    // Handle Image Deletions if requested via delete_image_ids[] array
    if (!empty($input['delete_image_ids']) && is_array($input['delete_image_ids'])) {
        foreach ($input['delete_image_ids'] as $imgId) {
            $imgId = (int)$imgId;
            $imgFetch = $db->prepare("SELECT image_url FROM property_images WHERE id = :id AND property_id = :pid");
            $imgFetch->execute([':id' => $imgId, ':pid' => $propertyId]);
            $imgRow = $imgFetch->fetch();
            if ($imgRow) {
                $absPath = __DIR__ . '/../../' . ltrim($imgRow['image_url'], '/');
                if (file_exists($absPath)) {
                    @unlink($absPath);
                }
                $delImgStmt = $db->prepare("DELETE FROM property_images WHERE id = :id");
                $delImgStmt->execute([':id' => $imgId]);
            }
        }
    }

    // Handle New Image Uploads (handles both 'images' and 'images[]' keys)
    $rawFiles = $_FILES['images'] ?? $_FILES['images[]'] ?? null;
    if (!empty($rawFiles)) {
        // Count existing images
        $countStmt = $db->prepare("SELECT COUNT(*) as cnt FROM property_images WHERE property_id = :pid");
        $countStmt->execute([':pid' => $propertyId]);
        $existingCount = (int)$countStmt->fetch()['cnt'];

        $uploadedFiles = [];
        if (is_array($rawFiles['name'])) {
            $newFileCount = count($rawFiles['name']);
            if (($existingCount + $newFileCount) > MAX_PROPERTY_IMAGES) {
                sendJsonResponse(false, "Cannot exceed " . MAX_PROPERTY_IMAGES . " total images per property.", null, 400);
            }
            for ($i = 0; $i < $newFileCount; $i++) {
                if (!empty($rawFiles['name'][$i])) {
                    $file = [
                        'name'     => $rawFiles['name'][$i],
                        'type'     => $rawFiles['type'][$i],
                        'tmp_name' => $rawFiles['tmp_name'][$i],
                        'error'    => $rawFiles['error'][$i],
                        'size'     => $rawFiles['size'][$i]
                    ];
                    $valError = validateUploadedImage($file);
                    if ($valError !== null) {
                        sendJsonResponse(false, "New image #".($i+1)." error: " . $valError, null, 400);
                    }
                    $uploadedFiles[] = $file;
                }
            }
        } else if (!empty($rawFiles['name'])) {
            $valError = validateUploadedImage($rawFiles);
            if ($valError !== null) {
                sendJsonResponse(false, "New image error: " . $valError, null, 400);
            }
            $uploadedFiles[] = $rawFiles;
        }

        $sortOrder = $existingCount + 1;
        $imgInsertStmt = $db->prepare("INSERT INTO property_images (property_id, image_url, sort_order) VALUES (:pid, :url, :sort)");

        foreach ($uploadedFiles as $file) {
            $relativePath = savePropertyImage($file, $propertyId, $sortOrder);
            $imgInsertStmt->execute([
                ':pid'  => $propertyId,
                ':url'  => $relativePath,
                ':sort' => $sortOrder
            ]);
            $sortOrder++;
        }
    }

    sendJsonResponse(true, "Property updated successfully.", [
        "id" => $propertyId
    ]);

} catch (Exception $e) {
    error_log("Property update error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to update property: " . $e->getMessage(), null, 500);
}
