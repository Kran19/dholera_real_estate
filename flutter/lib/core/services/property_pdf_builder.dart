import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/property_model.dart';

/**
 * Native A4 PDF Binary Builder for Property Catalogue Brochures
 * DHOLERA REAL ESTATE — Generates True application/pdf Binary Stream
 */
class PropertyPdfBuilder {
  static Future<Uint8List> buildPdf(PropertyModel property) async {
    final pdf = pw.Document();

    // Fetch primary property photo bytes if available
    pw.ImageProvider? primaryImageProvider;
    if (property.primaryImage != null && property.primaryImage!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(property.primaryImage!)).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          primaryImageProvider = pw.MemoryImage(response.bodyBytes);
        }
      } catch (_) {
        // Fallback silently if image fetch times out
      }
    }

    final String titleStr = '${property.villageName} Plot (Survey No: ${property.surveyNo})';
    final String areaStr = '${property.area} ${property.areaUnit}';
    final String tpFpStr = 'TP: ${property.tp ?? "-"} | FP: ${property.fp ?? "-"}';
    final String roadStr = property.road.isNotEmpty ? property.road : 'Main Sector Road Touch';
    final String refStr = property.reference != null && property.reference!.isNotEmpty ? property.reference! : 'N/A';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // TOP BRANDING HEADER BANNER
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  color: PdfColor.fromHex('#0F172A'),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DHOLERA REAL ESTATE',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Official Property Catalogue Brochure',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromHex('#93C5FD'),
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#1E3A8A'),
                          borderRadius: pw.BorderRadius.circular(16),
                        ),
                        child: pw.Text(
                          'Call: +91 98765 43210',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // BODY CONTENT CONTAINER
                pw.Padding(
                  padding: const pw.EdgeInsets.all(28),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // TITLE & BADGE
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#DBEAFE'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          '${property.zone} Zone • Dholera SIR',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E40AF'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        titleStr,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0F172A'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Village: ${property.villageName} | Zone: ${property.zone} | Dholera SIR, Gujarat',
                        style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#64748B')),
                      ),
                      pw.SizedBox(height: 16),

                      // SPECIFICATIONS GRID
                      pw.Row(
                        children: [
                          _buildSpecBox('Plot / Area', areaStr),
                          pw.SizedBox(width: 10),
                          _buildSpecBox('Road Width', roadStr),
                          pw.SizedBox(width: 10),
                          _buildSpecBox('TP / FP No.', tpFpStr),
                          pw.SizedBox(width: 10),
                          _buildSpecBox('Property Code', '#DRE-${property.id}'),
                        ],
                      ),
                      pw.SizedBox(height: 20),

                      // PRIMARY IMAGE / PHOTO CONTAINER
                      if (primaryImageProvider != null) ...[
                        pw.Container(
                          height: 180,
                          width: double.infinity,
                          decoration: pw.BoxDecoration(
                            borderRadius: pw.BorderRadius.circular(8),
                            image: pw.DecorationImage(
                              image: primaryImageProvider,
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 20),
                      ],

                      // DETAILS TABLE & HIGHLIGHTS
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'PROPERTY SPECIFICATIONS',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#1E3A8A'),
                                  ),
                                ),
                                pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
                                pw.SizedBox(height: 4),
                                _buildDetailRow('Village Name:', property.villageName),
                                _buildDetailRow('Survey Number:', property.surveyNo),
                                _buildDetailRow('Zone:', property.zone),
                                _buildDetailRow('Town Planning (TP):', property.tp ?? '-'),
                                _buildDetailRow('Final Plot (FP):', property.fp ?? '-'),
                                _buildDetailRow('Road Connection:', roadStr),
                                _buildDetailRow('Reference:', refStr),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'KEY HIGHLIGHTS',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#1E3A8A'),
                                  ),
                                ),
                                pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
                                pw.SizedBox(height: 4),
                                _buildBulletPoint('100% Clear Title & Verified'),
                                _buildBulletPoint('Immediate Registry & Possession'),
                                _buildBulletPoint('Dholera SIR Master Plan Zone'),
                                _buildBulletPoint('Near Expressway & Airport Hub'),
                                _buildBulletPoint('Underground Smart City Infra'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // FOOTER BANNER
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  color: PdfColor.fromHex('#0F172A'),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Interested in this property? Contact us today!',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#60A5FA'),
                            ),
                          ),
                          pw.Text(
                            'DHOLERA REAL ESTATE — Your Trusted Investment Partner',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromHex('#94A3B8'),
                            ),
                          ),
                        ],
                      ),
                      pw.Text(
                        'emperorsmartsolutions.com',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSpecBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F1F5F9'),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#64748B')),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A')),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#64748B')),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A')),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text('✓ ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#16A34A'))),
          pw.Text(text, style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#1E293B'))),
        ],
      ),
    );
  }
}
