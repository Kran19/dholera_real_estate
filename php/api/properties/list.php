<?php
/**
 * Property Listing Endpoint (Authenticated Users & Super Admin)
 * DHOLERA REAL ESTATE
 * GET /api/properties/list.php
 */

require_once __DIR__ . '/../../middleware/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, "Method Not Allowed. Use GET.", null, 405);
}

try {
    $db = Database::getConnection();
    $baseUrl = getBaseUrl();

    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = min(100, max(1, (int)($_GET['limit'] ?? 10)));
    $offset = ($page - 1) * $limit;

    $search = trim($_GET['search'] ?? '');
    $villageFilter = trim($_GET['village_name'] ?? '');
    $zoneFilter = trim($_GET['zone'] ?? '');
    $areaUnitFilter = trim($_GET['area_unit'] ?? '');

    $where = [];
    $params = [];

    if ($search !== '') {
        $where[] = "(p.village_name LIKE :search OR p.survey_no LIKE :search OR p.reference LIKE :search)";
        $params[':search'] = '%' . $search . '%';
    }

    if ($villageFilter !== '') {
        $where[] = "p.village_name = :village_name";
        $params[':village_name'] = $villageFilter;
    }

    if ($zoneFilter !== '') {
        $where[] = "p.zone = :zone";
        $params[':zone'] = $zoneFilter;
    }

    if ($areaUnitFilter !== '') {
        $where[] = "p.area_unit = :area_unit";
        $params[':area_unit'] = $areaUnitFilter;
    }

    $whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    // Total Count
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM properties p $whereClause");
    $countStmt->execute($params);
    $total = (int)$countStmt->fetch()['total'];
    $totalPages = (int)ceil($total / $limit);

    // Main Query
    $sql = "
        SELECT p.*, u.username as creator_name
        FROM properties p
        LEFT JOIN users u ON u.id = p.created_by
        $whereClause
        ORDER BY p.id DESC
        LIMIT $limit OFFSET $offset
    ";
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $properties = $stmt->fetchAll();

    // Attach Property Images
    foreach ($properties as &$prop) {
        $imgStmt = $db->prepare("SELECT id, image_url, sort_order FROM property_images WHERE property_id = :pid ORDER BY sort_order ASC");
        $imgStmt->execute([':pid' => $prop['id']]);
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
    }

    sendJsonResponse(true, "Properties retrieved successfully.", [
        "properties" => $properties
    ], 200, [
        "page"        => $page,
        "limit"       => $limit,
        "total"       => $total,
        "total_pages" => $totalPages
    ]);

} catch (Exception $e) {
    error_log("Property listing error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve properties: " . $e->getMessage(), null, 500);
}
