<?php
/**
 * DHOLERA REAL ESTATE — SUPER ADMIN ACCOUNT PROVISIONER & RESET
 * URL: /reset_admin.php
 * 
 * Safely creates or updates the requested Super Admin credentials in the live MySQL database.
 */

require_once __DIR__ . '/bootstrap.php';

header('Content-Type: text/html; charset=utf-8');

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Account Provisioner — Dholera Real Estate</title>
    <style>
        :root { --primary: #1e3a8a; --bg: #0f172a; --card: #1e293b; --text: #f8fafc; --success: #4ade80; --border: #334155; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background-color: var(--bg); color: var(--text); padding: 2rem; max-width: 700px; margin: 0 auto; line-height: 1.6; }
        .card { background-color: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 2rem; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.4); }
        h1 { color: #ffffff; margin-top: 0; font-size: 1.6rem; display: flex; align-items: center; gap: 0.5rem; }
        .success-box { background: rgba(74, 222, 128, 0.12); border: 1px solid var(--success); color: var(--success); padding: 1rem 1.25rem; border-radius: 8px; margin-bottom: 1.5rem; font-weight: 600; }
        .account-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        .account-table th, .account-table td { padding: 0.75rem 1rem; text-align: left; border-bottom: 1px solid var(--border); }
        .account-table th { background: rgba(255,255,255,0.04); color: #94a3b8; font-size: 0.85rem; text-transform: uppercase; }
        .badge { display: inline-block; padding: 0.2rem 0.6rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; background: #3b82f6; color: #fff; }
        .code { font-family: monospace; font-size: 1.05rem; color: #38bdf8; font-weight: bold; background: #020617; padding: 0.2rem 0.5rem; border-radius: 4px; }
        .btn { display: inline-block; background: #2563eb; color: #ffffff; text-decoration: none; padding: 0.75rem 1.5rem; border-radius: 8px; font-weight: 600; margin-top: 1.5rem; }
        .btn:hover { background: #1d4ed8; }
        pre { background: #020617; color: #f87171; padding: 1rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🔐 Admin Account Provisioner</h1>

<?php
try {
    $db = Database::getConnection();

    // Ensure users table exists
    $db->exec("
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) NOT NULL UNIQUE,
            password_hash VARCHAR(255) NOT NULL,
            role ENUM('super_admin', 'user') NOT NULL DEFAULT 'user',
            status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $accounts = [
        [
            'username' => 'parmit',
            'password' => '123456',
            'role'     => 'super_admin',
            'status'   => 'active'
        ],
        [
            'username' => 'admin',
            'password' => 'Admin@123',
            'role'     => 'super_admin',
            'status'   => 'active'
        ]
    ];

    $results = [];

    foreach ($accounts as $acc) {
        $hash = password_hash($acc['password'], PASSWORD_DEFAULT);
        
        $stmt = $db->prepare("SELECT id, username FROM users WHERE username = :username");
        $stmt->execute([':username' => $acc['username']]);
        $existing = $stmt->fetch();

        if ($existing) {
            $upStmt = $db->prepare("
                UPDATE users 
                SET password_hash = :hash, role = :role, status = :status 
                WHERE id = :id
            ");
            $upStmt->execute([
                ':hash'   => $hash,
                ':role'   => $acc['role'],
                ':status' => $acc['status'],
                ':id'     => $existing['id']
            ]);
            $action = 'Updated & Activated';
        } else {
            $insStmt = $db->prepare("
                INSERT INTO users (username, password_hash, role, status) 
                VALUES (:username, :hash, :role, :status)
            ");
            $insStmt->execute([
                ':username' => $acc['username'],
                ':hash'     => $hash,
                ':role'     => $acc['role'],
                ':status'   => $acc['status']
            ]);
            $action = 'Newly Created & Activated';
        }

        $results[] = [
            'username' => $acc['username'],
            'password' => $acc['password'],
            'role'     => $acc['role'],
            'action'   => $action
        ];
    }

    echo "<div class='success-box'>✅ Super Admin accounts successfully configured in the database!</div>";
    echo "<p>You can now immediately log in with the credentials below:</p>";

    echo "<table class='account-table'>";
    echo "<thead><tr><th>Username</th><th>Password</th><th>Role</th><th>Status</th></tr></thead>";
    echo "<tbody>";
    foreach ($results as $r) {
        echo "<tr>";
        echo "<td><span class='code'>" . htmlspecialchars($r['username']) . "</span></td>";
        echo "<td><span class='code'>" . htmlspecialchars($r['password']) . "</span></td>";
        echo "<td><span class='badge'>" . htmlspecialchars($r['role']) . "</span></td>";
        echo "<td style='color: var(--success); font-weight: 600;'>" . htmlspecialchars($r['action']) . "</td>";
        echo "</tr>";
    }
    echo "</tbody></table>";

    echo "<div style='text-align: center;'>";
    echo "<a href='app/' class='btn'>Go to Web Portal Login →</a>";
    echo "</div>";

} catch (Throwable $e) {
    echo "<div style='color: #f87171; font-weight: bold; margin-bottom: 1rem;'>❌ Error provisioning accounts:</div>";
    echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
}
?>

    </div>
</body>
</html>
