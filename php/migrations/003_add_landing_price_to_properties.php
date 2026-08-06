<?php
/**
 * Migration 003: Add Landing Price to Properties Table
 * DHOLERA REAL ESTATE
 */

return function(PDO $db) {
    // Add landing_price column safely if missing
    $cols = $db->query("SHOW COLUMNS FROM properties LIKE 'landing_price'")->fetch();
    if (!$cols) {
        $db->exec("ALTER TABLE properties ADD COLUMN landing_price VARCHAR(100) DEFAULT NULL AFTER reference;");
    }
};
