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

    // Fetch property details safely without non-existent table joins
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

    // Fetch property images
    $imgStmt = $db->prepare("SELECT image_url FROM property_images WHERE property_id = :id ORDER BY id ASC");
    $imgStmt->execute([':id' => $propertyId]);
    $images = $imgStmt->fetchAll(PDO::FETCH_COLUMN);

    $baseUrl = 'https://emperorsmartsolutions.com/dholerarealestate/php';
    
    // Resolve absolute image URLs
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
    $road = !empty($property['road']) ? htmlspecialchars($property['road']) : 'Main Road Touch';
    $area = number_format((float)($property['area'] ?? 0), 2);
    $areaUnit = htmlspecialchars($property['area_unit'] ?? 'Sq Yard');
    $reference = !empty($property['reference']) ? htmlspecialchars($property['reference']) : 'N/A';

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
            .header { background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%); color: #ffffff; padding: 24px 32px; display: flex; justify-content: space-between; align-items: center; border-bottom: 4px solid #3b82f6; }
            .brand-logo { display: flex; align-items: center; gap: 12px; }
            .brand-logo-icon { width: 44px; height: 44px; background: #ffffff; color: #1e3a8a; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: 900; }
            .brand-name { font-size: 22px; font-weight: 800; letter-spacing: 1px; }
            .brand-tagline { font-size: 11px; color: #93c5fd; text-transform: uppercase; letter-spacing: 1.5px; margin-top: 2px; }
            .contact-pill { background: rgba(255,255,255,0.12); padding: 8px 16px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.25); font-size: 13px; font-weight: 600; }
            .content { padding: 28px 32px; flex-grow: 1; }
            .property-meta-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
            .badge { background: #dbeafe; color: #1e40af; font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 6px; text-transform: uppercase; letter-spacing: 0.5px; display: inline-block; margin-bottom: 8px; }
            .property-title { font-size: 24px; font-weight: 800; color: #0f172a; margin: 0 0 6px 0; line-height: 1.25; }
            .property-location { font-size: 13px; color: #64748b; display: flex; align-items: center; gap: 6px; }
            .price-tag { text-align: right; background: #f0fdf4; border: 1px solid #bbf7d0; padding: 10px 18px; border-radius: 12px; }
            .price-label { font-size: 10px; color: #166534; text-transform: uppercase; font-weight: 700; letter-spacing: 0.5px; }
            .price-amount { font-size: 20px; font-weight: 900; color: #15803d; margin-top: 2px; }
            .specs-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin: 20px 0; }
            .spec-card { background: #f1f5f9; padding: 12px; border-radius: 10px; border-left: 3px solid #1e3a8a; }
            .spec-label { font-size: 10px; color: #64748b; text-transform: uppercase; font-weight: 600; }
            .spec-value { font-size: 14px; font-weight: 700; color: #0f172a; margin-top: 4px; }
            .gallery-container { display: grid; grid-template-columns: 2fr 1fr; gap: 12px; margin-bottom: 24px; }
            .main-img { width: 100%; height: 220px; object-fit: cover; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.08); }
            .side-gallery { display: flex; flex-direction: column; gap: 12px; }
            .sub-img { width: 100%; height: 104px; object-fit: cover; border-radius: 10px; }
            .details-section { display: grid; grid-template-columns: 1.5fr 1fr; gap: 20px; margin-bottom: 20px; }
            .section-title { font-size: 14px; font-weight: 700; color: #1e3a8a; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; padding-bottom: 6px; margin-bottom: 10px; letter-spacing: 0.5px; }
            .description-text { font-size: 12px; line-height: 1.6; color: #334155; }
            .amenities-list { list-style: none; padding: 0; margin: 0; }
            .amenities-list li { font-size: 12px; color: #1e293b; margin-bottom: 8px; display: flex; align-items: center; gap: 8px; }
            .amenities-list li::before { content: "✓"; color: #16a34a; font-weight: 900; background: #dcfce7; width: 18px; height: 18px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 10px; }
            .footer { background: #0f172a; color: #ffffff; padding: 20px 32px; display: flex; justify-content: space-between; align-items: center; border-top: 3px solid #3b82f6; }
            .footer-cta { font-size: 14px; font-weight: 700; color: #60a5fa; }
            .footer-contacts { display: flex; gap: 20px; font-size: 12px; }
            .footer-item { display: flex; align-items: center; gap: 6px; color: #cbd5e1; }
            .footer-item strong { color: #ffffff; }
            .print-bar { background: #1e3a8a; color: white; text-align: center; padding: 10px; font-weight: 600; cursor: pointer; }
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
                <div class="property-meta-row">
                    <div>
                        <span class="badge"><?php echo $zone; ?> • Dholera SIR</span>
                        <h1 class="property-title"><?php echo $displayTitle; ?></h1>
                        <div class="property-location">
                            📍 Village: <?php echo $villageName; ?> | Zone: <?php echo $zone; ?> | Dholera SIR
                        </div>
                    </div>
                    <div class="price-tag">
                        <div class="price-label">Property Code</div>
                        <div class="price-amount">#DRE-<?php echo $property['id']; ?></div>
                    </div>
                </div>

                <div class="specs-grid">
                    <div class="spec-card">
                        <div class="spec-label">Plot / Area</div>
                        <div class="spec-value"><?php echo $area . ' ' . $areaUnit; ?></div>
                    </div>
                    <div class="spec-card">
                        <div class="spec-label">Road Touch</div>
                        <div class="spec-value"><?php echo $road; ?></div>
                    </div>
                    <div class="spec-card">
                        <div class="spec-label">TP / FP No.</div>
                        <div class="spec-value">TP: <?php echo $tp; ?> | FP: <?php echo $fp; ?></div>
                    </div>
                    <div class="spec-card">
                        <div class="spec-label">Survey No.</div>
                        <div class="spec-value"><?php echo $surveyNo; ?></div>
                    </div>
                </div>

                <div class="gallery-container">
                    <img src="<?php echo htmlspecialchars($mainImage); ?>" class="main-img" alt="Main Photo">
                    <div class="side-gallery">
                        <img src="<?php echo htmlspecialchars($sideImage1); ?>" class="sub-img" alt="Side Photo 1">
                        <img src="<?php echo htmlspecialchars($sideImage2); ?>" class="sub-img" alt="Side Photo 2">
                    </div>
                </div>

                <div class="details-section">
                    <div>
                        <div class="section-title">Property Information & Notes</div>
                        <div class="description-text">
                            Village: <strong><?php echo $villageName; ?></strong><br>
                            Survey Number: <strong><?php echo $surveyNo; ?></strong><br>
                            Zone: <strong><?php echo $zone; ?></strong><br>
                            Road Connection: <strong><?php echo $road; ?></strong><br>
                            Town Planning (TP): <strong><?php echo $tp; ?></strong> | Final Plot (FP): <strong><?php echo $fp; ?></strong><br>
                            Reference: <strong><?php echo $reference; ?></strong>
                        </div>
                    </div>
                    <div>
                        <div class="section-title">Key Highlights</div>
                        <ul class="amenities-list">
                            <li>100% Verified Title Clearance</li>
                            <li>Immediate Registry & Possession</li>
                            <li>Dholera SIR Special Investment Region</li>
                            <li>Near Expressway & Airport Hub</li>
                            <li>Underground Smart City Infrastructure</li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="footer">
                <div>
                    <div class="footer-cta">Interested in this property? Contact us today!</div>
                    <div style="font-size: 11px; color: #94a3b8; margin-top: 2px;">DHOLERA REAL ESTATE — Your Trusted Investment Partner</div>
                </div>
                <div class="footer-contacts">
                    <div class="footer-item">
                        <span>📞</span> <strong>+91 98765 43210</strong>
                    </div>
                    <div class="footer-item">
                        <span>🌐</span> <strong>emperorsmartsolutions.com</strong>
                    </div>
                </div>
            </div>
        </div>
    </body>
    </html>
    <?php

} catch (Throwable $e) {
    sendJsonResponse(false, "Failed to generate PDF brochure: " . $e->getMessage(), null, 500);
}
