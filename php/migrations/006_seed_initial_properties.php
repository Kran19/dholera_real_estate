<?php
/**
 * Migration 006: Seed Initial Property Listings
 * DHOLERA REAL ESTATE
 */

return function(PDO $db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM properties");
    $count = (int)$stmt->fetch()['count'];

    if ($count === 0) {
        $userStmt = $db->query("SELECT id FROM users ORDER BY id ASC LIMIT 1");
        $admin = $userStmt->fetch();
        $adminId = $admin ? (int)$admin['id'] : 1;

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
                'landing_price' => '2500/SqYd',
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
                'landing_price' => '45 Lac/Bigha',
                'created_by' => $adminId
            ],
            [
                'village_name' => 'Pachi',
                'survey_no' => '45/A',
                'zone' => 'Industrial',
                'tp' => 'TP-1',
                'fp' => 'FP-22',
                'road' => '55 Mtr',
                'area' => 1500.00,
                'area_unit' => 'Sq Yard',
                'reference' => 'High-impact Industrial Plot Dholera SIR',
                'landing_price' => '3200/SqYd',
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
                'landing_price' => '2800/SqYd',
                'created_by' => $adminId
            ]
        ];

        $insertProp = $db->prepare("
            INSERT INTO properties (village_name, survey_no, zone, tp, fp, road, area, area_unit, reference, landing_price, created_by)
            VALUES (:village_name, :survey_no, :zone, :tp, :fp, :road, :area, :area_unit, :reference, :landing_price, :created_by)
        ");

        foreach ($sampleProperties as $p) {
            $insertProp->execute($p);
        }
    }
};
