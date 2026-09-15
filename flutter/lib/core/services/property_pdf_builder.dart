import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/property_model.dart';

/// Property PDF Presentation & Brochure Builder
/// DHOLERA REAL ESTATE — Portrait A4 Format with Expanded Specs & Zero Blank Space
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

    final String villageName = property.villageName;
    final String surveyNo = property.surveyNo;
    final String zoneStr = property.zone.isNotEmpty ? property.zone : 'Industrial';
    final String tpStr = (property.tp != null && property.tp!.isNotEmpty) ? property.tp! : '-';
    final String fpStr = (property.fp != null && property.fp!.isNotEmpty) ? property.fp! : '-';
    final String roadStr = property.road.isNotEmpty ? property.road : 'Main Sector Road Touch';
    final String areaSqYd = '${property.area} ${property.areaUnit}';

    // Calculate Square Meters (1 Sq Yard = ~0.836127 Sq Meter)
    final double sqMetersNum = property.area * 0.836127;
    final String areaSqM = '${sqMetersNum.toStringAsFixed(0)} Sq. Meter';

    final String displayTitle = '$villageName Plot (Survey No: $surveyNo)';

    // -------------------------------------------------------------------------
    // PAGE 1: Full-Page Portrait Catalogue Page with Expanded Specifications
    // -------------------------------------------------------------------------
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
                _buildHeader(
                  title: 'DHOLERA REAL ESTATE',
                  subtitle: 'Official Property Catalogue Brochure',
                  badgeText: 'Official Property Catalogue',
                ),

                // Main Body
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        // Top Map View Container
                        if (mapImage1 != null) ...[
                          pw.Container(
                            height: 250,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F8FAFC'),
                              borderRadius: pw.BorderRadius.circular(12),
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 11,
                              verticalRadius: 11,
                              child: pw.Center(
                                child: pw.Image(
                                  mapImage1,
                                  fit: pw.BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 16),
                        ],

                        // Title & Zone Row with Big Fonts
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                displayTitle,
                                softWrap: true,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0F172A'),
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 12),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#DBEAFE'),
                                borderRadius: pw.BorderRadius.circular(8),
                              ),
                              child: pw.Text(
                                '$zoneStr Zone • Dholera SIR',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#1E40AF'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 16),

                        // Expanded Specifications Box (Takes full remaining space)
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(20),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F8FAFC'),
                              borderRadius: pw.BorderRadius.circular(14),
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'PROPERTY SPECIFICATIONS & DETAILS',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#1E3A8A'),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Divider(color: PdfColor.fromHex('#CBD5E1'), thickness: 1),
                                pw.SizedBox(height: 12),
                                pw.Expanded(
                                  child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      // Left Column (Big Fonts & Spacing)
                                      pw.Expanded(
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildLargeDetailRow('Village Name:', villageName),
                                            _buildLargeDetailRow('Survey Number:', surveyNo),
                                            _buildLargeDetailRow('Zoning:', zoneStr),
                                            _buildLargeDetailRow('Town Planning:', tpStr),
                                            _buildLargeDetailRow('Final Plot (FP):', fpStr),
                                          ],
                                        ),
                                      ),
                                      pw.SizedBox(width: 24),
                                      // Right Column (Big Fonts & Spacing)
                                      pw.Expanded(
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildLargeDetailRow('Road Touch:', roadStr),
                                            _buildLargeDetailRow('Area Size (SqYd):', areaSqYd),
                                            _buildLargeDetailRow('Area Size (SqM):', areaSqM),
                                            _buildLargeDetailRow('Title Clearance:', '100% Clear'),
                                            _buildLargeDetailRow('Plot Status:', 'Ready N.A. Plot'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    // -------------------------------------------------------------------------
    // PAGE 2: Primary Property View & DP Zone Map
    // -------------------------------------------------------------------------
    if (imageProviders.isNotEmpty || mapImage2 != null) {
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
                  _buildHeader(
                    title: 'DHOLERA REAL ESTATE',
                    subtitle: 'Official Property Catalogue Brochure',
                    badgeText: 'Gallery — Page 2',
                  ),

                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(24),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          if (mapImage2 != null) ...[
                            pw.Expanded(
                              flex: 5,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#F8FAFC'),
                                  borderRadius: pw.BorderRadius.circular(12),
                                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
                                ),
                                child: pw.ClipRRect(
                                  horizontalRadius: 11,
                                  verticalRadius: 11,
                                  child: pw.Center(
                                    child: pw.Image(mapImage2, fit: pw.BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 16),
                          ],

                          if (imageProviders.isNotEmpty) ...[
                            pw.Expanded(
                              flex: 6,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#F8FAFC'),
                                  borderRadius: pw.BorderRadius.circular(12),
                                  border: pw.Border.all(color: PdfColor.fromHex('#1E3A8A'), width: 2),
                                ),
                                child: pw.ClipRRect(
                                  horizontalRadius: 11,
                                  verticalRadius: 11,
                                  child: pw.Center(
                                    child: pw.Image(imageProviders[0], fit: pw.BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  _buildFooter(),
                ],
              ),
            );
          },
        ),
      );
    }

    // -------------------------------------------------------------------------
    // PAGE 3: Dholera SIR Master Plan Infographic (Images-03)
    // -------------------------------------------------------------------------
    if (mapImage3 != null) {
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
                  _buildHeader(
                    title: 'DHOLERA REAL ESTATE',
                    subtitle: 'Official Property Catalogue Brochure',
                    badgeText: 'Master Plan',
                  ),

                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(24),
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F8FAFC'),
                          borderRadius: pw.BorderRadius.circular(12),
                          border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
                        ),
                        child: pw.ClipRRect(
                          horizontalRadius: 11,
                          verticalRadius: 11,
                          child: pw.Center(
                            child: pw.Image(mapImage3!, fit: pw.BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                  ),

                  _buildFooter(),
                ],
              ),
            );
          },
        ),
      );
    }

    // -------------------------------------------------------------------------
    // PAGE 4+: Additional Property Gallery Images
    // -------------------------------------------------------------------------
    if (imageProviders.length >= 2) {
      for (int i = 1; i < imageProviders.length; i++) {
        final currentImage = imageProviders[i];

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
                    _buildHeader(
                      title: 'DHOLERA REAL ESTATE',
                      subtitle: 'Official Property Catalogue Brochure',
                      badgeText: 'Document — Page ${i + 3}',
                    ),

                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(24),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F8FAFC'),
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 11,
                            verticalRadius: 11,
                            child: pw.Center(
                              child: pw.Image(currentImage, fit: pw.BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                    ),

                    _buildFooter(),
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

  /// Builds standardized branded top banner
  static pw.Widget _buildHeader({
    required String title,
    required String subtitle,
    required String badgeText,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      color: PdfColor.fromHex('#0F172A'),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                  fontSize: 9.5,
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
              badgeText,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds clean branded footer banner (Zero broken unicode icons & Zero Property Code)
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#60A5FA'),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'DHOLERA REAL ESTATE - Your Trusted Investment Partner',
                style: pw.TextStyle(
                  fontSize: 8.5,
                  color: PdfColor.fromHex('#94A3B8'),
                ),
              ),
            ],
          ),
          pw.Text(
            'Dholera SIR Special Investment Region',
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#94A3B8'),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds large, high-impact detail row with clear font hierarchy
  static pw.Widget _buildLargeDetailRow(String label, String value, {double labelWidth = 110}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: labelWidth,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColor.fromHex('#475569'),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              softWrap: true,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F172A'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
