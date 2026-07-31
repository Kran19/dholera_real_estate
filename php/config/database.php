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
$envPaths = [__DIR__ . '/../.env', __DIR__ . '/../../.env'];
foreach ($envPaths as $envPath) {
    if (file_exists($envPath)) {
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

if (!defined('DB_HOST')) define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
if (!defined('DB_NAME')) define('DB_NAME', getenv('DB_NAME') ?: 'dholera_realestate');
if (!defined('DB_USER')) define('DB_USER', getenv('DB_USER') ?: 'root');
if (!defined('DB_PASS')) define('DB_PASS', getenv('DB_PASS') !== false ? getenv('DB_PASS') : '');
if (!defined('DB_PORT')) define('DB_PORT', getenv('DB_PORT') ?: '3306');
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
            } catch (PDOException $e) {
                // Log detailed error locally
                error_log("Database Connection Error: " . $e->getMessage());
                throw new Exception("Database connection failed: " . $e->getMessage());
            }
        }

        return self::$instance;
    }
}
