<?php
/**
 * Migration 007: Add / Update Super Admin Account (parmit)
 * DHOLERA REAL ESTATE
 */

return function(PDO $db) {
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

    foreach ($accounts as $acc) {
        $hash = password_hash($acc['password'], PASSWORD_DEFAULT);
        $stmt = $db->prepare("SELECT id FROM users WHERE username = :username");
        $stmt->execute([':username' => $acc['username']]);
        $existing = $stmt->fetch();

        if ($existing) {
            $update = $db->prepare("
                UPDATE users 
                SET password_hash = :hash, role = :role, status = :status 
                WHERE id = :id
            ");
            $update->execute([
                ':hash'   => $hash,
                ':role'   => $acc['role'],
                ':status' => $acc['status'],
                ':id'     => $existing['id']
            ]);
        } else {
            $insert = $db->prepare("
                INSERT INTO users (username, password_hash, role, status) 
                VALUES (:username, :hash, :role, :status)
            ");
            $insert->execute([
                ':username' => $acc['username'],
                ':hash'     => $hash,
                ':role'     => $acc['role'],
                ':status'   => $acc['status']
            ]);
        }
    }
};
