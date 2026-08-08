<?php
/**
 * All Inquiries Endpoint (Super Admin Only) — No Pagination
 * DHOLERA REAL ESTATE
 * GET /api/inquiries/all.php
 *
 * Returns ALL inquiries ordered by id ASC for circular batch calculation.
 * Used by the "Calls Today" feature to determine today's 10-contact batch.
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
            INDEX idx_inquiries_id (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    // Count total
    $total = (int)$db->query("SELECT COUNT(*) as total FROM inquiries")->fetch()['total'];

    // Fetch ALL records ordered by id ASC — stable index for batch math
    $stmt = $db->prepare("
        SELECT i.id, i.customer_name, i.customer_city, i.customer_mobile,
               i.requirement, i.notes, i.created_at
        FROM inquiries i
        ORDER BY i.id ASC
    ");
    $stmt->execute();
    $inquiries = $stmt->fetchAll();

    foreach ($inquiries as &$inq) {
        $inq['id']          = (int)$inq['id'];
        $inq['requirement'] = $inq['requirement'] ?? '';
        $inq['notes']       = $inq['notes'] ?? '';
    }
    unset($inq);

    sendJsonResponse(true, "All inquiries retrieved successfully.", [
        "inquiries" => $inquiries,
        "total"     => $total,
    ]);

} catch (Throwable $e) {
    error_log("Inquiry all error: " . $e->getMessage());
    sendJsonResponse(false, "Failed to retrieve inquiries: " . $e->getMessage(), null, 500);
}
