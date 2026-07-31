<?php
/**
 * Database Configuration & PDO Connection Wrapper
 * DHOLERA REAL ESTATE
 * 
 * Local Development: WAMP Server (MySQL @ localhost:3306)
 * Database Name: dholera_realestate
 * Username: root
 * Password: (EMPTY)
 */

// Load .env configuration file if present
$envPaths = [
    __DIR__ . '/../.env',
    __DIR__ . '/../../.env',
    dirname(__DIR__) . '/.env',
    $_SERVER['DOCUMENT_ROOT'] . '/.env',
    $_SERVER['DOCUMENT_ROOT'] . '/dholerarealestate/php/.env'
];

foreach ($envPaths as $envPath) {
    if (!empty($envPath) && file_exists($envPath)) {
        $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if (empty($line) || strpos($line, '#') === 0) continue;
            if (strpos($line, '=') !== false) {
                list($name, $value) = explode('=', $line, 2);
                $key = trim($name);
                $val = trim($value, '"\' ');
                putenv("$key=$val");
                $_ENV[$key] = $val;
                $_SERVER[$key] = $val;
            }
        }
        break;
    }
}

// Smart Environment Detection (Hostinger Live vs Local WAMP)
$isLiveServer = file_exists(__DIR__ . '/../.env')
    || file_exists(__DIR__ . '/../../.env')
    || (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'emperorsmartsolutions.com') !== false)
    || (isset($_SERVER['SERVER_NAME']) && strpos($_SERVER['SERVER_NAME'], 'emperorsmartsolutions') !== false)
    || (strpos(__DIR__, 'emperorsmartsolutions') !== false || strpos(__DIR__, 'u362391755') !== false);

if ($isLiveServer) {
    $dbHost = getenv('DB_HOST') ?: ($_ENV['DB_HOST'] ?? $_SERVER['DB_HOST'] ?? 'localhost');
    $dbName = getenv('DB_NAME') ?: ($_ENV['DB_NAME'] ?? $_SERVER['DB_NAME'] ?? 'u362391755_dhorelareal');
    $dbUser = getenv('DB_USER') ?: ($_ENV['DB_USER'] ?? $_SERVER['DB_USER'] ?? 'u362391755_dholerareal');
    $dbPass = getenv('DB_PASS') !== false && getenv('DB_PASS') !== '' 
        ? getenv('DB_PASS') 
        : ($_ENV['DB_PASS'] ?? $_SERVER['DB_PASS'] ?? 'Emperor@Admin07');
    $dbPort = getenv('DB_PORT') ?: ($_ENV['DB_PORT'] ?? $_SERVER['DB_PORT'] ?? '3306');
} else {
    $dbHost = 'localhost';
    $dbName = 'dholera_realestate';
    $dbUser = 'root';
    $dbPass = '';
    $dbPort = '3306';
}

if (!defined('DB_HOST')) define('DB_HOST', $dbHost);
if (!defined('DB_NAME')) define('DB_NAME', $dbName);
if (!defined('DB_USER')) define('DB_USER', $dbUser);
if (!defined('DB_PASS')) define('DB_PASS', $dbPass);
if (!defined('DB_PORT')) define('DB_PORT', $dbPort);
if (!defined('DB_CHARSET')) define('DB_CHARSET', 'utf8mb4');

class Database {
    private static ?PDO $instance = null;

    /**
     * Get Singleton PDO Instance
     */
    public static function getConnection(): PDO {
        if (self::$instance === null) {
            $dsn = sprintf(
                "mysql:host=%s;port=%s;dbname=%s;charset=%s",
                DB_HOST,
                DB_PORT,
                DB_NAME,
                DB_CHARSET
            );

            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
            ];

            try {
                self::$instance = new PDO($dsn, DB_USER, DB_PASS, $options);

                // Auto-Migrate inquiries table if missing for zero-downtime deployment
                @self::$instance->exec("
                    CREATE TABLE IF NOT EXISTS inquiries (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        customer_name VARCHAR(100) NOT NULL,
                        customer_city VARCHAR(100) NOT NULL,
                        customer_mobile VARCHAR(20) NOT NULL,
                        notes TEXT NULL,
                        created_by INT NOT NULL,
                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        INDEX (created_at),
                        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                ");

            } catch (PDOException $e) {
                // Log detailed error locally
                error_log("Database Connection Error: " . $e->getMessage());
                throw new Exception("Database connection failed: " . $e->getMessage());
            }
        }

        return self::$instance;
    }
}
