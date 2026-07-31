<?php
/**
 * Inquiry List Endpoint (Super Admin Only)
 * DHOLERA REAL ESTATE
 * GET /api/inquiries/list.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, "Method Not Allowed. Use GET.", null, 405);
}

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

    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
    $offset = ($page - 1) * $limit;
    $search = trim($_GET['search'] ?? '');

    $where = [];
    $params = [];

    if ($search !== '') {
        $where[] = "(i.customer_name LIKE :search OR i.customer_city LIKE :search OR i.customer_mobile LIKE :search OR i.requirement LIKE :search OR i.notes LIKE :search)";
        $params[':search'] = '%' . $search . '%';
    }

    $whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    // Count total
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM inquiries i $whereClause");
    $countStmt->execute($params);
    $total = (int)$countStmt->fetch()['total'];
    $totalPages = (int)ceil($total / $limit);

    // Fetch records
    $sql = "
        SELECT i.*, u.username as creator_name
        FROM inquiries i
        LEFT JOIN users u ON u.id = i.created_by
        $whereClause
        ORDER BY i.id DESC
        LIMIT $limit OFFSET $offset
    ";
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $inquiries = $stmt->fetchAll();

    foreach ($inquiries as &$inq) {
        $inq['id'] = (int)$inq['id'];
    }

    sendJsonResponse(true, "Inquiries retrieved successfully.", [
        "inquiries" => $inquiries
    ], 200, [
        "page"        => $page,
        "limit"       => $limit,
        "total"       => $total,
        "total_pages" => $totalPages
    ]);

} catch (Throwable $e) {
    error_log("Inquiry list error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve inquiries: " . $e->getMessage(), null, 500);
}
