import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/property_model.dart';

/// Property PDF Presentation Builder
/// DHOLERA REAL ESTATE — Modern Proposal Presentation Format
class PropertyPdfBuilder {
  static Future<Uint8List> buildPdf(PropertyModel property) async {
    final pdf = pw.Document();

    // 1. Fetch bytes for all property photos asynchronously with timeouts
    final List<pw.ImageProvider> imageProviders = [];
    for (var img in property.images) {
      if (img.imageUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(img.imageUrl)).timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            imageProviders.add(pw.MemoryImage(response.bodyBytes));
          }
        } catch (_) {}
      }
    }

    if (imageProviders.isEmpty && property.primaryImage != null && property.primaryImage!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(property.primaryImage!)).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          imageProviders.add(pw.MemoryImage(response.bodyBytes));
        }
      } catch (_) {}
    }

    // 2. Fetch local map templates from assets
    pw.ImageProvider? mapImage1;
    pw.ImageProvider? mapImage2;
    pw.ImageProvider? mapImage3;

    try {
      final ByteData data1 = await rootBundle.load('assets/images/Images-01.jpg.jpeg');
      mapImage1 = pw.MemoryImage(data1.buffer.asUint8List());
    } catch (_) {}

    try {
      final ByteData data2 = await rootBundle.load('assets/images/Images-02.jpg.jpeg');
      mapImage2 = pw.MemoryImage(data2.buffer.asUint8List());
    } catch (_) {}

    try {
      final ByteData data3 = await rootBundle.load('assets/images/Images-03.jpg.jpeg');
      mapImage3 = pw.MemoryImage(data3.buffer.asUint8List());
    } catch (_) {}

    final String villageName = property.villageName.toUpperCase();
    final String surveyNo = property.surveyNo;
    final String zoneStr = property.zone.isNotEmpty ? property.zone.toUpperCase() : 'INDUSTRIAL';
    final String tpStr = (property.tp != null && property.tp!.isNotEmpty) ? property.tp! : '-';
    final String fpStr = (property.fp != null && property.fp!.isNotEmpty) ? property.fp! : '-';
    final String roadStr = property.road.isNotEmpty ? property.road : '18m TP Road';
    final String areaSqYd = '${property.area}';

    // Calculate Square Meters (1 Sq Yard = ~0.836127 Sq Meter)
    final double sqMetersNum = property.area * 0.836127;
    final String areaSqM = sqMetersNum.toStringAsFixed(0);

    // -------------------------------------------------------------------------
    // PAGE 1: Modern Deep Navy Cover Page (Matching Sample Page 1)
    // -------------------------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColor.fromHex('#0A192F'),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'DHOLERA',
                    style: pw.TextStyle(
                      fontSize: 40,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '$zoneStr PROPOSAL',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Container(
                    width: 320,
                    height: 2,
                    color: PdfColors.white,
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'VILLAGE - $villageName',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#93C5FD'),
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'DHOLERA SIR',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // -------------------------------------------------------------------------
    // PAGE 2: Property Specifications & Activation Map (Matching Sample Page 2)
    // -------------------------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white,
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'VILLAGE - $villageName',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#0F172A'),
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Column: Bullet List
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBulletItem('NEW SURVEY No. – $surveyNo'),
                            _buildBulletItem('OLD SURVEY No. – ${surveyNo}p'),
                            _buildBulletItem('TP $tpStr'),
                            _buildBulletItem('FINAL PLOT (FP) – $fpStr'),
                            _buildBulletItem('TP ROAD – $roadStr'),
                            _buildBulletItem('AREA IN SQ. YARD – $areaSqYd'),
                            _buildBulletItem('AREA IN METER – $areaSqM'),
                            _buildBulletItem('READY NA'),
                            _buildBulletItem('ZONING – $zoneStr'),
                            _buildBulletItem('ALL TITLE CLEAR'),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      // Right Column: Activation Map
                      pw.Expanded(
                        flex: 6,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F8FAFC'),
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 11,
                            verticalRadius: 11,
                            child: mapImage1 != null
                                ? pw.Image(mapImage1, fit: pw.BoxFit.contain)
                                : pw.Center(child: pw.Text('Activation Map')),
                          ),
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

    // -------------------------------------------------------------------------
    // PAGE 3: Zone - DP Location (Matching Sample Page 3)
    // -------------------------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Top Purple/Navy Header Banner
                pw.Container(
                  color: PdfColor.fromHex('#1E1B4B'),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: pw.Text(
                    '$zoneStr ZONE – DP LOCATION',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                // Body: Dual Display
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(24),
                    child: pw.Row(
                      children: [
                        // DP Map
                        pw.Expanded(
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(10),
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 9,
                              verticalRadius: 9,
                              child: mapImage2 != null
                                  ? pw.Image(mapImage2, fit: pw.BoxFit.contain)
                                  : pw.Center(child: pw.Text('DP Map')),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        // Primary Site / CAD Photo
                        pw.Expanded(
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F8FAFC'),
                              borderRadius: pw.BorderRadius.circular(10),
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 9,
                              verticalRadius: 9,
                              child: imageProviders.isNotEmpty
                                  ? pw.Image(imageProviders[0], fit: pw.BoxFit.contain)
                                  : (mapImage2 != null
                                      ? pw.Image(mapImage2, fit: pw.BoxFit.contain)
                                      : pw.Center(child: pw.Text('Site Plan'))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // -------------------------------------------------------------------------
    // PAGE 4: Open Plot Location & Metric Callouts (Matching Sample Page 4)
    // -------------------------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white,
            child: pw.Column(
              children: [
                pw.SizedBox(height: 20),
                // Top Header Pill Container
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#4338CA'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  child: pw.Text(
                    'OPEN PLOT LOCATION',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                // Body
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: pw.Row(
                      children: [
                        // Left Metric Stack
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              _buildMetricCard('AREA IN SQYD : $areaSqYd'),
                              pw.SizedBox(height: 16),
                              _buildMetricCard('AREA IN METERS : $areaSqM'),
                              pw.SizedBox(height: 16),
                              _buildMetricCard('TP ROAD : $roadStr'),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        // Right CAD/Plot View
                        pw.Expanded(
                          flex: 6,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F8FAFC'),
                              borderRadius: pw.BorderRadius.circular(12),
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 11,
                              verticalRadius: 11,
                              child: imageProviders.length >= 2
                                  ? pw.Image(imageProviders[1], fit: pw.BoxFit.contain)
                                  : (imageProviders.isNotEmpty
                                      ? pw.Image(imageProviders[0], fit: pw.BoxFit.contain)
                                      : pw.Center(child: pw.Text('Plot CAD View'))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // -------------------------------------------------------------------------
    // PAGE 5: Dholera SIR Master Plan Infographic (Matching Sample Page 8)
    // -------------------------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white,
            child: pw.Column(
              children: [
                pw.SizedBox(height: 18),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#4338CA'),
                    borderRadius: pw.BorderRadius.circular(14),
                  ),
                  child: pw.Text(
                    'MASTER PLAN DHOLERA SIR',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(16),
                    child: mapImage3 != null
                        ? pw.Image(mapImage3, fit: pw.BoxFit.contain)
                        : pw.Center(child: pw.Text('Dholera SIR Master Plan Infographic')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // -------------------------------------------------------------------------
    // PAGE 6+: Uploaded Property Documents & Scans (NA Order / Zoning Cert / Photos)
    // -------------------------------------------------------------------------
    if (imageProviders.length >= 3) {
      for (int i = 2; i < imageProviders.length; i++) {
        final currentImage = imageProviders[i];
        final String docTitle = (i == 2) ? 'NA ORDER' : ((i == 3) ? 'ZONING CERTIFICATE' : 'PROPERTY DOCUMENT ${i - 1}');

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.Container(
                color: PdfColors.white,
                child: pw.Row(
                  children: [
                    // Left Purple Title Bar (Matching Sample Page 5 NA Order layout)
                    pw.Container(
                      width: 220,
                      color: PdfColor.fromHex('#4338CA'),
                      child: pw.Center(
                        child: pw.Text(
                          docTitle,
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    // Right Document Scan Area
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F8FAFC'),
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 9,
                            verticalRadius: 9,
                            child: pw.Center(
                              child: pw.Image(currentImage, fit: pw.BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  /// Helper to build bullet point specification item
  static pw.Widget _buildBulletItem(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 6,
          height: 6,
          decoration: const pw.BoxDecoration(
            color: PdfColors.black,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Helper to build rounded metric card
  static pw.Widget _buildMetricCard(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#4338CA'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
