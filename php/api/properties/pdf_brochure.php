<?php
/**
 * Property PDF Presentation Generator Endpoint
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

    $villageName = strtoupper(htmlspecialchars($property['village_name'] ?? 'DHOLERA'));
    $surveyNo = htmlspecialchars($property['survey_no'] ?? '-');
    $zone = !empty($property['zone']) ? strtoupper(htmlspecialchars($property['zone'])) : 'INDUSTRIAL';
    $tp = !empty($property['tp']) ? htmlspecialchars($property['tp']) : '-';
    $fp = !empty($property['fp']) ? htmlspecialchars($property['fp']) : '-';
    $road = !empty($property['road']) ? htmlspecialchars($property['road']) : '18m TP Road';
    $areaVal = (float)($property['area'] ?? 0);
    $areaSqYd = number_format($areaVal, 2);
    $areaSqM = number_format($areaVal * 0.836127, 0);

    $displayTitle = "DHOLERA $zone PROPOSAL — VILLAGE $villageName";

    header("Content-Type: text/html; charset=UTF-8");
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><?php echo $displayTitle; ?> — Property Presentation</title>
        <style>
            @page { size: A4 landscape; margin: 0; }
            * { box-sizing: border-box; -webkit-print-color-adjust: exact; }
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: #0a192f; color: #0f172a; }
            .print-bar { background: #1e3a8a; color: white; text-align: center; padding: 12px; font-weight: 700; cursor: pointer; font-size: 14px; position: fixed; top: 0; width: 100%; z-index: 1000; box-shadow: 0 4px 10px rgba(0,0,0,0.3); }
            @media print { .print-bar { display: none; } }

            .page-slide { width: 297mm; height: 210mm; margin: 0 auto 20px auto; background: #ffffff; position: relative; page-break-after: always; overflow: hidden; display: flex; flex-direction: column; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }
            
            /* Cover Slide */
            .slide-cover { background: #0a192f; color: #ffffff; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; }
            .cover-title { font-size: 48px; font-weight: 900; letter-spacing: 4px; margin: 0; }
            .cover-subtitle { font-size: 28px; font-weight: 800; letter-spacing: 2px; margin-top: 8px; color: #ffffff; }
            .cover-divider { width: 360px; height: 3px; background: #ffffff; margin: 20px 0; }
            .cover-village { font-size: 22px; font-weight: 800; color: #93c5fd; letter-spacing: 1.5px; }
            .cover-sir { font-size: 16px; color: #cbd5e1; letter-spacing: 2px; margin-top: 6px; }

            /* Page 2 Specs Slide */
            .slide-body { padding: 40px; height: 100%; display: flex; flex-direction: column; justify-content: space-between; }
            .slide-title { font-size: 32px; font-weight: 900; color: #0f172a; margin-bottom: 24px; letter-spacing: 1px; }
            .specs-split { display: flex; gap: 40px; height: 100%; align-items: stretch; }
            .specs-list { flex: 1; display: flex; flex-direction: column; justify-content: space-around; list-style: none; padding: 0; margin: 0; }
            .specs-list li { font-size: 18px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 14px; }
            .specs-list li::before { content: "•"; color: #0a192f; font-size: 24px; }
            .specs-map-box { flex: 1.2; border: 2px solid #cbd5e1; border-radius: 14px; overflow: hidden; background: #f8fafc; display: flex; align-items: center; justify-content: center; }
            .specs-map-box img { width: 100%; height: 100%; object-fit: contain; }

            /* Header Banners & Pills */
            .header-banner { background: #1e1b4b; color: #ffffff; padding: 20px 40px; font-size: 26px; font-weight: 900; letter-spacing: 1.5px; }
            .header-pill { background: #4338ca; color: #ffffff; padding: 14px 44px; border-radius: 20px; font-size: 24px; font-weight: 900; letter-spacing: 1.5px; margin: 24px auto 12px auto; display: inline-block; }

            /* Metric Stack */
            .metrics-split { display: flex; gap: 40px; padding: 20px 40px 40px 40px; height: 100%; align-items: center; }
            .metric-stack { flex: 1; display: flex; flex-direction: column; gap: 20px; justify-content: center; }
            .metric-card { background: #4338ca; color: #ffffff; padding: 18px 28px; border-radius: 14px; font-size: 18px; font-weight: 800; letter-spacing: 1px; text-align: left; box-shadow: 0 4px 10px rgba(67,56,202,0.2); }
            .metric-image-box { flex: 1.3; height: 100%; border: 2px solid #cbd5e1; border-radius: 14px; overflow: hidden; background: #f8fafc; }
            .metric-image-box img { width: 100%; height: 100%; object-fit: contain; }

            /* Dual Display Slide */
            .dual-grid { display: flex; gap: 24px; padding: 24px 40px; height: calc(100% - 80px); }
            .dual-card { flex: 1; border: 2px solid #cbd5e1; border-radius: 12px; overflow: hidden; background: #f8fafc; }
            .dual-card img { width: 100%; height: 100%; object-fit: contain; }

            /* Document Slide */
            .doc-split { display: flex; height: 100%; }
            .doc-side-bar { width: 260px; background: #4338ca; color: #ffffff; display: flex; align-items: center; justify-content: center; padding: 30px; text-align: center; }
            .doc-side-title { font-size: 28px; font-weight: 900; letter-spacing: 2px; }
            .doc-content { flex: 1; padding: 30px; display: flex; align-items: center; justify-content: center; }
            .doc-box { width: 100%; height: 100%; border: 2px solid #cbd5e1; border-radius: 14px; overflow: hidden; background: #f8fafc; }
            .doc-box img { width: 100%; height: 100%; object-fit: contain; }
        </style>
    </head>
    <body>
        <div class="print-bar" onclick="window.print()">🖨️ Click Here to Print or Save Presentation PDF Brochure</div>

        <div style="padding-top: 60px;">
            <!-- SLIDE 1: Cover Slide -->
            <div class="page-slide slide-cover">
                <h1 class="cover-title">DHOLERA</h1>
                <div class="cover-subtitle"><?php echo $zone; ?> PROPOSAL</div>
                <div class="cover-divider"></div>
                <div class="cover-village">VILLAGE - <?php echo $villageName; ?></div>
                <div class="cover-sir">DHOLERA SIR</div>
            </div>

            <!-- SLIDE 2: Specifications & Activation Map -->
            <div class="page-slide">
                <div class="slide-body">
                    <h2 class="slide-title">VILLAGE - <?php echo $villageName; ?></h2>
                    <div class="specs-split">
                        <ul class="specs-list">
                            <li>NEW SURVEY No. – <?php echo $surveyNo; ?></li>
                            <li>OLD SURVEY No. – <?php echo $surveyNo; ?>p</li>
                            <li>TP <?php echo $tp; ?></li>
                            <li>TP ROAD – <?php echo $road; ?></li>
                            <li>AREA IN SQ. YARD – <?php echo $areaSqYd; ?></li>
                            <li>AREA IN METER – <?php echo $areaSqM; ?></li>
                            <li>READY NA</li>
                            <li>ZONING – <?php echo $zone; ?></li>
                            <li>ALL TITLE CLEAR</li>
                        </ul>
                        <div class="specs-map-box">
                            <img src="<?php echo htmlspecialchars($baseUrl . '/../flutter/assets/images/Images-01.jpg.jpeg'); ?>" alt="Activation Map">
                        </div>
                    </div>
                </div>
            </div>

            <!-- SLIDE 3: Zone DP Location -->
            <div class="page-slide">
                <div class="header-banner">
                    <?php echo $zone; ?> ZONE – DP LOCATION
                </div>
                <div class="dual-grid">
                    <div class="dual-card">
                        <img src="<?php echo htmlspecialchars($baseUrl . '/../flutter/assets/images/Images-02.jpg.jpeg'); ?>" alt="DP Location Map">
                    </div>
                    <div class="dual-card">
                        <img src="<?php echo htmlspecialchars($mainImage); ?>" alt="Site Photo">
                    </div>
                </div>
            </div>

            <!-- SLIDE 4: Open Plot Location & Metrics -->
            <div class="page-slide" style="text-align: center;">
                <div class="header-pill">OPEN PLOT LOCATION</div>
                <div class="metrics-split">
                    <div class="metric-stack">
                        <div class="metric-card">AREA IN SQYD : <?php echo $areaSqYd; ?></div>
                        <div class="metric-card">AREA IN METERS : <?php echo $areaSqM; ?></div>
                        <div class="metric-card">TP ROAD : <?php echo $road; ?></div>
                    </div>
                    <div class="metric-image-box">
                        <img src="<?php echo htmlspecialchars($sideImage1); ?>" alt="Plot CAD View">
                    </div>
                </div>
            </div>

            <!-- SLIDE 5: Dholera SIR Master Plan Infographic -->
            <div class="page-slide" style="text-align: center;">
                <div class="header-pill">MASTER PLAN DHOLERA SIR</div>
                <div style="flex: 1; padding: 20px 40px 40px 40px;">
                    <img src="<?php echo htmlspecialchars($baseUrl . '/../flutter/assets/images/Images-03.jpg.jpeg'); ?>" style="width: 100%; height: 100%; object-fit: contain;" alt="Master Plan Infographic">
                </div>
            </div>

            <!-- SLIDE 6+: Additional Documents / Photos -->
            <?php for ($i = 2; $i < count($imageUrlList); $i++): 
                $docTitle = ($i == 2) ? 'NA ORDER' : (($i == 3) ? 'ZONING CERTIFICATE' : 'DOCUMENT ' . ($i - 1));
            ?>
                <div class="page-slide">
                    <div class="doc-split">
                        <div class="doc-side-bar">
                            <div class="doc-side-title"><?php echo $docTitle; ?></div>
                        </div>
                        <div class="doc-content">
                            <div class="doc-box">
                                <img src="<?php echo htmlspecialchars($imageUrlList[$i]); ?>" alt="<?php echo $docTitle; ?>">
                            </div>
                        </div>
                    </div>
                </div>
            <?php endfor; ?>
        </div>
    </body>
    </html>
    <?php

} catch (Throwable $e) {
    sendJsonResponse(false, "Failed to generate presentation brochure: " . $e->getMessage(), null, 500);
}
