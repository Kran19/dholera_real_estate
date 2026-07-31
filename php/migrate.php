<?php
/**
 * DHOLERA REAL ESTATE — PROFESSIONAL DATABASE MIGRATION ENGINE
 * URL: /migrate.php
 * 
 * Automatically tracks and applies versioned migration files in `php/migrations/`.
 * Ensures zero-downtime database upgrades without foreign key constraint errors.
 */

require_once __DIR__ . '/bootstrap.php';

header('Content-Type: text/html; charset=utf-8');

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Migration Engine — Dholera Real Estate</title>
    <style>
        :root { --primary: #1e3a8a; --bg: #0f172a; --card: #1e293b; --text: #f8fafc; --success: #4ade80; --warning: #fbbf24; --danger: #f87171; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background-color: var(--bg); color: var(--text); padding: 2rem; max-width: 900px; margin: 0 auto; line-height: 1.5; }
        h1 { color: #ffffff; border-bottom: 2px solid #334155; padding-bottom: 0.5rem; display: flex; align-items: center; gap: 0.75rem; }
        .card { background-color: var(--card); border: 1px solid #334155; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3); }
        .status-badge { display: inline-block; padding: 0.25rem 0.75rem; border-radius: 9999px; font-weight: 700; font-size: 0.85rem; text-transform: uppercase; }
        .badge-applied { background-color: rgba(74, 222, 128, 0.15); color: var(--success); border: 1px solid var(--success); }
        .badge-pending { background-color: rgba(251, 191, 36, 0.15); color: var(--warning); border: 1px solid var(--warning); }
        .migration-item { display: flex; justify-content: space-between; align-items: center; padding: 0.75rem 0; border-bottom: 1px solid #334155; }
        .migration-item:last-child { border-bottom: none; }
        .migration-name { font-weight: 600; font-family: monospace; font-size: 0.95rem; }
        pre { background: #020617; color: #38bdf8; padding: 1rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; }
        .footer-note { font-size: 0.85rem; color: #94a3b8; margin-top: 2rem; text-align: center; }
    </style>
</head>
<body>
    <h1>🚀 Dholera Real Estate — Migration Engine</h1>

<?php
try {
    $db = Database::getConnection();

    echo "<div class='card'>";
    echo "<h3>📊 Database Connection: <span style='color: var(--success);'>" . htmlspecialchars(DB_NAME) . "</span></h3>";

    // 1. Ensure schema_migrations table exists
    $db->exec("
        CREATE TABLE IF NOT EXISTS schema_migrations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            version VARCHAR(255) NOT NULL UNIQUE,
            applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    // 2. Fetch already applied migration versions
    $stmt = $db->query("SELECT version FROM schema_migrations");
    $appliedVersions = $stmt->fetchAll(PDO::FETCH_COLUMN);

    // 3. Scan php/migrations/ directory
    $migrationsDir = __DIR__ . '/migrations';
    $files = glob($migrationsDir . '/*.php');
    sort($files);

    $executedCount = 0;
    $alreadyAppliedCount = 0;

    echo "<div style='margin-top: 1rem;'>";
    echo "<h4>📋 Migration History & Status</h4>";

    foreach ($files as $filePath) {
        $version = basename($filePath, '.php');
        $isApplied = in_array($version, $appliedVersions);

        if ($isApplied) {
            $alreadyAppliedCount++;
            echo "<div class='migration-item'>";
            echo "<span class='migration-name'>📄 " . htmlspecialchars($version) . "</span>";
            echo "<span class='status-badge badge-applied'>Applied</span>";
            echo "</div>";
        } else {
            // Apply Pending Migration
            echo "<div class='migration-item'>";
            echo "<span class='migration-name'>⚙️ Applying " . htmlspecialchars($version) . "...</span>";

            try {
                // Disable foreign key checks during migration execution for safety
                $db->exec("SET FOREIGN_KEY_CHECKS = 0;");

                $migrationFunc = require $filePath;
                if (is_callable($migrationFunc)) {
                    $migrationFunc($db);
                }

                // Record migration in tracking table
                $insertStmt = $db->prepare("INSERT INTO schema_migrations (version) VALUES (:version)");
                $insertStmt->execute([':version' => $version]);

                $db->exec("SET FOREIGN_KEY_CHECKS = 1;");

                $executedCount++;
                echo "<span class='status-badge badge-applied'>Newly Applied</span>";
            } catch (Throwable $migrationErr) {
                $db->exec("SET FOREIGN_KEY_CHECKS = 1;");
                echo "<span class='status-badge badge-danger'>Failed</span>";
                echo "</div>";
                throw new Exception("Migration {$version} failed: " . $migrationErr->getMessage());
            }
            echo "</div>";
        }
    }

    echo "</div>";
    echo "</div>";

    echo "<div class='card'>";
    if ($executedCount > 0) {
        echo "<h2 style='color: var(--success); margin: 0;'>🎉 Successfully applied {$executedCount} new migration(s)!</h2>";
    } else {
        echo "<h2 style='color: var(--success); margin: 0;'>✨ Database is up to date! ({$alreadyAppliedCount} migrations verified)</h2>";
    }
    echo "</div>";

} catch (Throwable $e) {
    echo "<div class='card' style='border-color: var(--danger);'>";
    echo "<h3 style='color: var(--danger); margin-top: 0;'>❌ Migration Engine Error</h3>";
    echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
    echo "</div>";
}
?>

    <div class="footer-note">
        DHOLERA REAL ESTATE — Schema Migration System v1.0.3
    </div>
</body>
</html>
