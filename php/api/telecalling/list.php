<?php
/**
 * List Telecalling Contacts Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * GET /api/telecalling/list.php?search=query&page=1&limit=50
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, "Method Not Allowed. Use GET.", null, 405);
}

$search = trim($_GET['search'] ?? '');
$page   = max(1, (int)($_GET['page'] ?? 1));
$limit  = min(100, max(1, (int)($_GET['limit'] ?? 50)));
$offset = ($page - 1) * $limit;

try {
    $db = Database::getConnection();

    // Ensure table exists
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

    $whereClause = "WHERE status != 'moved_to_inquiry'";
    $params = [];

    if ($search !== '') {
        $whereClause .= " AND (name LIKE :search OR mobile LIKE :search OR city LIKE :search)";
        $params[':search'] = '%' . $search . '%';
    }

    $countStmt = $db->prepare("SELECT COUNT(*) FROM telecalling_contacts {$whereClause}");
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    $stmt = $db->prepare("
        SELECT id, name, mobile, city, notes, status, created_by, created_at, updated_at
        FROM telecalling_contacts
        {$whereClause}
        ORDER BY id DESC
        LIMIT :limit OFFSET :offset
    ");

    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v, PDO::PARAM_STR);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    $contacts = $stmt->fetchAll();
    foreach ($contacts as &$c) {
        $c['id'] = (int)$c['id'];
        $c['created_by'] = (int)$c['created_by'];
        $c['city'] = $c['city'] ?? '';
        $c['notes'] = $c['notes'] ?? '';
    }
    unset($c);

    sendJsonResponse(true, "Telecalling contacts retrieved successfully.", [
        'contacts'   => $contacts,
        'pagination' => [
            'total'       => $total,
            'page'        => $page,
            'limit'       => $limit,
            'total_pages' => ceil($total / $limit),
        ],
    ]);

} catch (Throwable $e) {
    error_log("List telecalling contacts error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve telecalling contacts: " . $e->getMessage(), null, 500);
}
