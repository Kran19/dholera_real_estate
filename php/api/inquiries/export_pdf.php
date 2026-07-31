<?php
/**
 * Export Inquiry List PDF / Printable Report Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/inquiries/export_pdf.php
 */

require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/admin.php';

try {
    $db = Database::getConnection();

    $stmt = $db->query("
        SELECT i.*, u.username as creator_name
        FROM inquiries i
        LEFT JOIN users u ON u.id = i.created_by
        ORDER BY i.id DESC
    ");
    $inquiries = $stmt->fetchAll();

    header("Content-Type: text/html; charset=UTF-8");
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Customer Inquiry Report — DHOLERA REAL ESTATE</title>
        <style>
            @page { size: A4; margin: 15mm; }
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #0f172a; margin: 0; padding: 20px; background: #fff; }
            .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #1e3a8a; padding-bottom: 15px; margin-bottom: 20px; }
            .brand { font-size: 22px; font-weight: 800; color: #1e3a8a; letter-spacing: 1px; }
            .title { font-size: 14px; color: #64748b; font-weight: 600; text-transform: uppercase; margin-top: 4px; }
            .meta { text-align: right; font-size: 12px; color: #475569; }
            table { width: 100%; border-collapse: collapse; margin-top: 15px; }
            th { background: #1e3a8a; color: #ffffff; font-size: 12px; text-transform: uppercase; padding: 10px; text-align: left; letter-spacing: 0.5px; }
            td { border-bottom: 1px solid #e2e8f0; padding: 10px; font-size: 13px; color: #334155; }
            tr:nth-child(even) { background-color: #f8fafc; }
            .phone { font-weight: 700; color: #1d4ed8; text-decoration: none; }
            .footer { margin-top: 30px; border-top: 1px solid #e2e8f0; padding-top: 12px; display: flex; justify-content: space-between; font-size: 11px; color: #94a3b8; }
            .print-btn { background: #1e3a8a; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 600; cursor: pointer; margin-bottom: 20px; }
            @media print { .print-btn { display: none; } }
        </style>
    </head>
    <body>
        <button class="print-btn" onclick="window.print()">🖨️ Print / Save as PDF</button>

        <div class="header">
            <div>
                <div class="brand">DHOLERA REAL ESTATE</div>
                <div class="title">Official Customer Inquiry Report</div>
            </div>
            <div class="meta">
                <div><strong>Generated:</strong> <?php echo date('d M Y, h:i A'); ?></div>
                <div><strong>Total Records:</strong> <?php echo count($inquiries); ?></div>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th style="width: 5%;">#</th>
                    <th style="width: 20%;">Customer Name</th>
                    <th style="width: 15%;">City</th>
                    <th style="width: 18%;">Mobile Number</th>
                    <th style="width: 25%;">Requirement</th>
                    <th style="width: 17%;">Notes / Date</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($inquiries)): ?>
                    <tr>
                        <td colspan="6" style="text-align: center; color: #94a3b8; padding: 20px;">No inquiry records found.</td>
                    </tr>
                <?php else: ?>
                    <?php $sr = 1; foreach ($inquiries as $inq): ?>
                        <tr>
                            <td><?php echo $sr++; ?></td>
                            <td><strong><?php echo htmlspecialchars($inq['customer_name']); ?></strong></td>
                            <td><?php echo htmlspecialchars($inq['customer_city']); ?></td>
                            <td><a href="tel:<?php echo htmlspecialchars($inq['customer_mobile']); ?>" class="phone">📞 <?php echo htmlspecialchars($inq['customer_mobile']); ?></a></td>
                            <td><strong><?php echo htmlspecialchars($inq['requirement'] ?? '-'); ?></strong></td>
                            <td><?php echo htmlspecialchars($inq['notes'] ?? '-'); ?><br><small style="color: #64748b;"><?php echo date('d/m/Y', strtotime($inq['created_at'])); ?></small></td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>

        <div class="footer">
            <div>DHOLERA REAL ESTATE — Internal Admin Inquiry Export</div>
            <div>Page 1 of 1</div>
        </div>
    </body>
    </html>
    <?php
} catch (Exception $e) {
    echo "Error generating report: " . htmlspecialchars($e->getMessage());
}
