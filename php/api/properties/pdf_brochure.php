<?php
/**
 * Property PDF Brochure Generator Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/properties/pdf_brochure.php?id={property_id}
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

$propertyId = (int)($_GET['id'] ?? 0);
if ($propertyId <= 0) {
    sendJsonResponse(false, "Invalid property ID.", null, 400);
}

try {
    $db = Database::getConnection();

    $stmt = $db->prepare("
        SELECT p.*, u.username as creator_name
        FROM properties p
        LEFT JOIN users u ON u.id = p.created_by
        WHERE p.id = :id
    ");
    $stmt->execute([':id' => $propertyId]);
    $property = $stmt->fetch();

    if (!$property) {
        sendJsonResponse(false, "Property not found.", null, 404);
    }

    $imgStmt = $db->prepare("SELECT image_url FROM property_images WHERE property_id = :id ORDER BY id ASC");
    $imgStmt->execute([':id' => $propertyId]);
    $images = $imgStmt->fetchAll(PDO::FETCH_COLUMN);

    $baseUrl = 'https://emperorsmartsolutions.com/dholerarealestate/php';
    
    $imageUrlList = [];
    if (!empty($images)) {
        foreach ($images as $img) {
            if (preg_match('#^https?://#i', $img)) {
                $imageUrlList[] = $img;
            } else {
                $cleanPath = preg_replace('#^php/#', '', ltrim($img, '/'));
                $imageUrlList[] = $baseUrl . '/' . $cleanPath;
            }
        }
    } else {
        $imageUrlList[] = 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&auto=format&fit=crop&q=80';
    }

    $mainImage = $imageUrlList[0];
    $sideImage1 = $imageUrlList[1] ?? $mainImage;
    $sideImage2 = $imageUrlList[2] ?? $sideImage1;

    $villageName = htmlspecialchars($property['village_name'] ?? 'Dholera');
    $surveyNo = htmlspecialchars($property['survey_no'] ?? '-');
    $zone = htmlspecialchars($property['zone'] ?? 'General Zone');
    $tp = !empty($property['tp']) ? htmlspecialchars($property['tp']) : '-';
    $fp = !empty($property['fp']) ? htmlspecialchars($property['fp']) : '-';
    $road = !empty($property['road']) ? htmlspecialchars($property['road']) : 'Main Sector Road Touch';
    $areaVal = (float)($property['area'] ?? 0);
    $areaSqYd = number_format($areaVal, 2) . ' ' . htmlspecialchars($property['area_unit'] ?? 'Sq Yard');
    $areaSqM = number_format($areaVal * 0.836127, 0) . ' Sq. Meter';

    $displayTitle = "$villageName Plot (Survey No: $surveyNo)";

    header("Content-Type: text/html; charset=UTF-8");
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><?php echo $displayTitle; ?> — Property Brochure</title>
        <style>
            @page { size: A4 portrait; margin: 0; }
            * { box-sizing: border-box; -webkit-print-color-adjust: exact; }
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: #f8fafc; color: #0f172a; }
            .brochure-container { width: 210mm; min-height: 297mm; margin: 0 auto; background: #ffffff; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%); color: #ffffff; padding: 20px 32px; display: flex; justify-content: space-between; align-items: center; border-bottom: 4px solid #3b82f6; }
            .brand-logo { display: flex; align-items: center; gap: 12px; }
            .brand-logo-icon { width: 44px; height: 44px; background: #ffffff; color: #1e3a8a; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: 900; }
            .brand-name { font-size: 22px; font-weight: 800; letter-spacing: 1px; }
            .brand-tagline { font-size: 11px; color: #93c5fd; text-transform: uppercase; letter-spacing: 1.5px; margin-top: 2px; }
            .contact-pill { background: rgba(255,255,255,0.12); padding: 8px 16px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.25); font-size: 13px; font-weight: 600; }
            .content { padding: 24px 32px; flex-grow: 1; display: flex; flex-direction: column; }
            .map-box { width: 100%; height: 260px; object-fit: contain; border-radius: 12px; border: 1px solid #cbd5e1; background: #f8fafc; margin-bottom: 20px; }
            .property-meta-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
            .badge { background: #dbeafe; color: #1e40af; font-size: 12px; font-weight: 800; padding: 6px 14px; border-radius: 8px; text-transform: uppercase; letter-spacing: 0.5px; }
            .property-title { font-size: 24px; font-weight: 900; color: #0f172a; margin: 0; line-height: 1.25; }
            .specs-card-container { flex-grow: 1; background: #f8fafc; border: 2px solid #cbd5e1; border-radius: 16px; padding: 24px; display: flex; flex-direction: column; justify-content: space-between; }
            .specs-card-title { font-size: 16px; font-weight: 800; color: #1e3a8a; letter-spacing: 0.8px; border-bottom: 2px solid #cbd5e1; padding-bottom: 10px; margin-bottom: 16px; }
            .specs-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
            .spec-item { display: flex; flex-direction: column; gap: 4px; }
            .spec-label { font-size: 13px; color: #475569; font-weight: 700; }
            .spec-value { font-size: 16px; font-weight: 900; color: #0f172a; }
            .footer { background: #0f172a; color: #ffffff; padding: 18px 32px; display: flex; justify-content: space-between; align-items: center; border-top: 3px solid #3b82f6; }
            .footer-cta { font-size: 14px; font-weight: 700; color: #60a5fa; }
            .footer-sub { font-size: 11px; color: #94a3b8; margin-top: 2px; }
            .print-bar { background: #1e3a8a; color: white; text-align: center; padding: 12px; font-weight: 700; cursor: pointer; }
            @media print { .print-bar { display: none; } }
        </style>
    </head>
    <body>
        <div class="print-bar" onclick="window.print()">🖨️ Click Here to Print or Save as PDF Brochure</div>
        <div class="brochure-container">
            <div class="header">
                <div class="brand-logo">
                    <div class="brand-logo-icon">🏢</div>
                    <div>
                        <div class="brand-name">DHOLERA REAL ESTATE</div>
                        <div class="brand-tagline">Official Property Catalogue Brochure</div>
                    </div>
                </div>
                <div class="contact-pill">
                    📞 +91 98765 43210
                </div>
            </div>

            <div class="content">
                <img src="<?php echo htmlspecialchars($baseUrl . '/../flutter/assets/images/Images-01.jpg.jpeg'); ?>" class="map-box" alt="Map View">

                <div class="property-meta-row">
                    <h1 class="property-title"><?php echo $displayTitle; ?></h1>
                    <span class="badge"><?php echo $zone; ?> Zone • Dholera SIR</span>
                </div>

                <div class="specs-card-container">
                    <div class="specs-card-title">PROPERTY SPECIFICATIONS & DETAILS</div>
                    <div class="specs-grid">
                        <div class="spec-item">
                            <span class="spec-label">Village Name:</span>
                            <span class="spec-value"><?php echo $villageName; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Road Touch:</span>
                            <span class="spec-value"><?php echo $road; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Survey Number:</span>
                            <span class="spec-value"><?php echo $surveyNo; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Area Size (SqYd):</span>
                            <span class="spec-value"><?php echo $areaSqYd; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Zoning:</span>
                            <span class="spec-value"><?php echo $zone; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Area Size (SqM):</span>
                            <span class="spec-value"><?php echo $areaSqM; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Town Planning (TP):</span>
                            <span class="spec-value"><?php echo $tp; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Title Clearance:</span>
                            <span class="spec-value" style="color: #16a34a;">100% Clear</span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Final Plot (FP):</span>
                            <span class="spec-value"><?php echo $fp; ?></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Plot Status:</span>
                            <span class="spec-value" style="color: #16a34a;">Ready N.A. Plot</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="footer">
                <div>
                    <div class="footer-cta">Interested in this property? Contact us today!</div>
                    <div class="footer-sub">DHOLERA REAL ESTATE - Your Trusted Investment Partner</div>
                </div>
                <div style="font-size: 12px; color: #cbd5e1; font-weight: 700;">
                    Dholera SIR Special Investment Region
                </div>
            </div>
        </div>
    </body>
    </html>
    <?php

} catch (Throwable $e) {
    sendJsonResponse(false, "Failed to generate PDF brochure: " . $e->getMessage(), null, 500);
}
