<?php
/**
 * Database Migration & Seed Script
 * DHOLERA REAL ESTATE
 * 
 * Run from terminal: php backend/database/seed.php
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/config.php';

echo "=== DHOLERA REAL ESTATE DATABASE SEEDER ===\n";

try {
    // 1. Connect without dbname to ensure database exists
    $pdo = new PDO("mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";charset=utf8mb4", DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "[1/4] Ensuring database '" . DB_NAME . "' exists...\n";
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `" . DB_NAME . "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");

    // 2. Connect to dholera_realestate database via Database class
    $db = Database::getConnection();

    echo "[2/4] Executing schema.sql DDL...\n";
    $sql = file_get_contents(__DIR__ . '/schema.sql');
    $db->exec($sql);

    echo "[3/4] Seeding default User accounts...\n";
    
    // Seed Super Admin
    $adminUsername = 'admin';
    $adminPassword = 'Admin@123';
    $adminHash = password_hash($adminPassword, PASSWORD_DEFAULT);

    $stmt = $db->prepare("SELECT id FROM users WHERE username = :username");
    $stmt->execute([':username' => $adminUsername]);
    $existingAdmin = $stmt->fetch();

    if (!$existingAdmin) {
        $insertAdmin = $db->prepare("INSERT INTO users (username, password_hash, role, status) VALUES (:username, :hash, 'super_admin', 'active')");
        $insertAdmin->execute([':username' => $adminUsername, ':hash' => $adminHash]);
        $adminId = $db->lastInsertId();
        echo " -> Created Super Admin account: username='admin', passcode='Admin@123'\n";
    } else {
        $adminId = $existingAdmin['id'];
        echo " -> Super Admin account 'admin' already exists.\n";
    }

    // Seed Normal User
    $userUsername = 'user1';
    $userPassword = 'User@123';
    $userHash = password_hash($userPassword, PASSWORD_DEFAULT);

    $stmt->execute([':username' => $userUsername]);
    $existingUser = $stmt->fetch();

    if (!$existingUser) {
        $insertUser = $db->prepare("INSERT INTO users (username, password_hash, role, status) VALUES (:username, :hash, 'user', 'active')");
        $insertUser->execute([':username' => $userUsername, ':hash' => $userHash]);
        echo " -> Created Normal User account: username='user1', passcode='User@123'\n";
    } else {
        echo " -> Normal User account 'user1' already exists.\n";
    }

    echo "[4/4] Seeding initial sample property listings...\n";
    $stmtPropCount = $db->query("SELECT COUNT(*) as count FROM properties");
    $propCount = $stmtPropCount->fetch()['count'];

    if ($propCount == 0) {
        $sampleProperties = [
            [
                'village_name' => 'Kadipur',
                'survey_no' => '102/A',
                'zone' => 'Residential',
                'tp' => 'TP-1',
                'fp' => 'FP-45',
                'road' => '24 Mtr',
                'area' => 500.00,
                'area_unit' => 'Sq Yard',
                'reference' => 'Direct Owner - Dholera SIR Zone',
                'created_by' => $adminId
            ],
            [
                'village_name' => 'Brimani',
                'survey_no' => '88/B',
                'zone' => 'Commercial',
                'tp' => 'TP-2',
                'fp' => 'FP-12',
                'road' => '55 Mtr Express Highway',
                'area' => 2.50,
                'area_unit' => 'Bigha',
                'reference' => 'Prime Commercial Plot near Activation Area',
                'created_by' => $adminId
            ],
            [
                'village_name' => 'Valinda',
                'survey_no' => '240/1',
                'zone' => 'Industrial',
                'tp' => 'TP-3',
                'fp' => 'FP-88',
                'road' => '30 Mtr',
                'area' => 1200.00,
                'area_unit' => 'Sq Yard',
                'reference' => 'Near Solar Park Road',
                'created_by' => $adminId
            ]
        ];

        $insertProp = $db->prepare("
            INSERT INTO properties (village_name, survey_no, zone, tp, fp, road, area, area_unit, reference, created_by)
            VALUES (:village_name, :survey_no, :zone, :tp, :fp, :road, :area, :area_unit, :reference, :created_by)
        ");

        foreach ($sampleProperties as $p) {
            $insertProp->execute($p);
        }
        echo " -> Seeded 3 sample properties successfully.\n";
    } else {
        echo " -> Property table already contains $propCount records.\n";
    }

    echo "=== SEEDING COMPLETED SUCCESSFULLY! ===\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
