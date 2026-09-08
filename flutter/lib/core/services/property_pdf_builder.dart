import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/property_model.dart';

/// Property PDF Document Builder
/// DHOLERA REAL ESTATE — A4 Format Brochure with Zero-Clipping & Scaled Visuals
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

    final String titleStr = '${property.villageName} Plot (Survey No: ${property.surveyNo})';
    final String areaStr = '${property.area} ${property.areaUnit}';
    final String roadStr = property.road.isNotEmpty ? property.road : 'Main Sector Road Touch';
    final String refStr = property.reference != null && property.reference!.isNotEmpty ? property.reference! : 'N/A';

    // -------------------------------------------------------------------------
    // PAGE 1: Master Sector Map 1 (Contain) + Comprehensive Specifications Table
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

                // Body Content Container
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        // Master Map 1 Container (BoxFit.contain so no map details are cut off)
                        if (mapImage1 != null) ...[
                          pw.Container(
                            height: 280,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F8FAFC'),
                              borderRadius: pw.BorderRadius.circular(10),
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 9,
                              verticalRadius: 9,
                              child: pw.Center(
                                child: pw.Image(
                                  mapImage1,
                                  fit: pw.BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 14),
                        ],

                        // Title & Zone Badge
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                titleStr,
                                softWrap: true,
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0F172A'),
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 12),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#DBEAFE'),
                                borderRadius: pw.BorderRadius.circular(6),
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
                          ],
                        ),
                        pw.SizedBox(height: 12),

                        // Specifications 2-Column Structured Card
                        pw.Container(
                          padding: const pw.EdgeInsets.all(14),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F8FAFC'),
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'PROPERTY SPECIFICATIONS & DETAILS',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#1E3A8A'),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              pw.Divider(color: PdfColor.fromHex('#CBD5E1'), thickness: 0.8),
                              pw.SizedBox(height: 6),
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Left Specifications Column
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow('Village Name:', property.villageName, labelWidth: 95),
                                        _buildDetailRow('Survey Number:', property.surveyNo, labelWidth: 95),
                                        _buildDetailRow('Zone:', property.zone, labelWidth: 95),
                                        _buildDetailRow('Town Planning:', property.tp ?? '-', labelWidth: 95),
                                        _buildDetailRow('Final Plot (FP):', property.fp ?? '-', labelWidth: 95),
                                      ],
                                    ),
                                  ),
                                  pw.SizedBox(width: 16),
                                  // Right Specifications Column
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow('Road Touch:', roadStr, labelWidth: 90),
                                        _buildDetailRow('Area Size:', areaStr, labelWidth: 90),
                                        if (property.landingPrice != null && property.landingPrice!.isNotEmpty)
                                          _buildDetailRow('Landing Price:', property.landingPrice!, labelWidth: 90),
                                        _buildDetailRow('Reference:', refStr, labelWidth: 90),
                                        _buildDetailRow('Property Code:', '#DRE-${property.id}', labelWidth: 90),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildFooter(property.id),
              ],
            ),
          );
        },
      ),
    );

    // -------------------------------------------------------------------------
    // PAGE 2: Master Map 2 (Contain) + Primary Property Photo (Enlarged Circle)
    // -------------------------------------------------------------------------
    if (imageProviders.isNotEmpty) {
      final firstImage = imageProviders[0];

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
                      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          // Top Map 2 Container (Contain mode)
                          if (mapImage2 != null) ...[
                            pw.Container(
                              height: 280,
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#F8FAFC'),
                                borderRadius: pw.BorderRadius.circular(10),
                                border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
                              ),
                              child: pw.ClipRRect(
                                horizontalRadius: 9,
                                verticalRadius: 9,
                                child: pw.Center(
                                  child: pw.Image(
                                    mapImage2,
                                    fit: pw.BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 20),
                          ],

                          // Enlarged Circular Primary Property View (290x290 with Navy Ring)
                          pw.Expanded(
                            child: pw.Center(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Container(
                                    width: 290,
                                    height: 290,
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColor.fromHex('#F1F5F9'),
                                      border: pw.Border.all(
                                        color: PdfColor.fromHex('#1E3A8A'),
                                        width: 4,
                                      ),
                                    ),
                                    child: pw.ClipOval(
                                      child: pw.Image(
                                        firstImage,
                                        fit: pw.BoxFit.cover,
                                        width: 290,
                                        height: 290,
                                      ),
                                    ),
                                  ),
                                  pw.SizedBox(height: 14),
                                  pw.Text(
                                    'Primary Property View',
                                    style: pw.TextStyle(
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromHex('#1E3A8A'),
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

                  _buildFooter(property.id),
                ],
              ),
            );
          },
        ),
      );
    }

    // -------------------------------------------------------------------------
    // PAGE 3: Master Map 3 (Contain) + Secondary Property Photo (Enlarged Rectangle)
    // -------------------------------------------------------------------------
    if (imageProviders.length >= 2) {
      final secondImage = imageProviders[1];

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
                    badgeText: 'Gallery — Page 3',
                  ),

                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          // Top Map 3 Container (Contain mode)
                          if (mapImage3 != null) ...[
                            pw.Container(
                              height: 280,
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#F8FAFC'),
                                borderRadius: pw.BorderRadius.circular(10),
                                border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
                              ),
                              child: pw.ClipRRect(
                                horizontalRadius: 9,
                                verticalRadius: 9,
                                child: pw.Center(
                                  child: pw.Image(
                                    mapImage3,
                                    fit: pw.BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 16),
                          ],

                          // Enlarged Rectangular Secondary Property View (460x280 with Contain)
                          pw.Expanded(
                            child: pw.Center(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Container(
                                    width: 460,
                                    height: 280,
                                    decoration: pw.BoxDecoration(
                                      color: PdfColor.fromHex('#F8FAFC'),
                                      borderRadius: pw.BorderRadius.circular(14),
                                      border: pw.Border.all(
                                        color: PdfColor.fromHex('#1E3A8A'),
                                        width: 2.5,
                                      ),
                                    ),
                                    child: pw.ClipRRect(
                                      horizontalRadius: 11,
                                      verticalRadius: 11,
                                      child: pw.Center(
                                        child: pw.Image(
                                          secondImage,
                                          fit: pw.BoxFit.contain,
                                          width: 460,
                                          height: 280,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.SizedBox(height: 14),
                                  pw.Text(
                                    'Secondary Property View',
                                    style: pw.TextStyle(
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromHex('#1E3A8A'),
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

                  _buildFooter(property.id),
                ],
              ),
            );
          },
        ),
      );
    }

    // -------------------------------------------------------------------------
    // PAGE 4+: Full Gallery Views for Remaining Photographs (BoxFit.contain)
    // -------------------------------------------------------------------------
    if (imageProviders.length >= 3) {
      for (int i = 2; i < imageProviders.length; i++) {
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
                      badgeText: 'Gallery — Page ${i + 2}',
                    ),

                    // Main image area with contain fit (100% visible, zero cropping)
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(24),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F8FAFC'),
                            borderRadius: pw.BorderRadius.circular(14),
                            border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 13,
                            verticalRadius: 13,
                            child: pw.Center(
                              child: pw.Image(
                                currentImage,
                                fit: pw.BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    _buildFooter(property.id),
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
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  color: PdfColor.fromHex('#93C5FD'),
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1E3A8A'),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Text(
              badgeText,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds standardized branded footer banner
  static pw.Widget _buildFooter(int propertyId) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#60A5FA'),
                ),
              ),
              pw.Text(
                'DHOLERA REAL ESTATE — Your Trusted Investment Partner',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  color: PdfColor.fromHex('#94A3B8'),
                ),
              ),
            ],
          ),
          pw.Text(
            'Property Code: #DRE-$propertyId',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#94A3B8'),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds robust detail row with Expanded wrapper and softWrap to prevent text clipping
  static pw.Widget _buildDetailRow(String label, String value, {double labelWidth = 95}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: labelWidth,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9.5,
                color: PdfColor.fromHex('#64748B'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              softWrap: true,
              style: pw.TextStyle(
                fontSize: 9.5,
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
