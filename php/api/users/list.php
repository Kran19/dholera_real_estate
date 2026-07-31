<?php
/**
 * User List Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * GET /api/users/list.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, "Method Not Allowed. Use GET.", null, 405);
}

try {
    $db = Database::getConnection();

    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
    $offset = ($page - 1) * $limit;
    $search = trim($_GET['search'] ?? '');

    $where = [];
    $params = [];

    if ($search !== '') {
        $where[] = "username LIKE :search";
        $params[':search'] = '%' . $search . '%';
    }

    $whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    // Count total
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM users $whereClause");
    $countStmt->execute($params);
    $total = (int)$countStmt->fetch()['total'];
    $totalPages = (int)ceil($total / $limit);

    // Fetch records
    $sql = "SELECT id, username, role, status, created_at, updated_at FROM users $whereClause ORDER BY id DESC LIMIT $limit OFFSET $offset";
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $users = $stmt->fetchAll();

    sendJsonResponse(true, "Users retrieved successfully.", [
        "users" => $users
    ], 200, [
        "page"        => $page,
        "limit"       => $limit,
        "total"       => $total,
        "total_pages" => $totalPages
    ]);

} catch (Exception $e) {
    error_log("User list error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve user list.", null, 500);
}
