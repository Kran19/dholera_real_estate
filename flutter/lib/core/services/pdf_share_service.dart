import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../../models/property_model.dart';
import 'property_pdf_builder.dart';

/**
 * Direct PDF Binary File & WhatsApp Attachment Sharing Service
 * DHOLERA REAL ESTATE — Generates & Shares True application/pdf Binary Files
 */
class PdfShareService {
  /// Shares Property Brochure PDF File on WhatsApp & Native Share Sheet
  static Future<void> sharePropertyPdf(BuildContext context, PropertyModel property) async {
    final titleStr = '${property.villageName} Plot (Survey No: ${property.surveyNo})';
    final sizeStr = '${property.area} ${property.areaUnit}';
    final locationStr = '${property.villageName}, Zone: ${property.zone}';
    final pdfUrl = '${ApiConfig.baseUrl}${ApiConfig.propertyExportPdf}?id=${property.id}';

    try {
      // Show non-blocking loading notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generating PDF Brochure for "$titleStr"...'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Generate native A4 PDF bytes
      final pdfBytes = await PropertyPdfBuilder.buildPdf(property);

      if (kIsWeb) {
        // Web Environment: Share/Print or Download PDF file natively
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'Dholera_Property_${property.id}.pdf',
        );
        return;
      }

      // Mobile (Android / iOS): Save PDF binary file and share via WhatsApp / System Share
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = titleStr.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final fileName = 'Dholera_Property_${property.id}_$sanitizedTitle.pdf';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);

      final xFile = XFile(
        filePath,
        mimeType: 'application/pdf',
        name: 'Dholera_Property_${property.id}.pdf',
      );

      final String shareText = '🏡 *Dholera Real Estate — Property Catalogue*\n\n'
          '📍 *$titleStr*\n'
          '📐 *Size:* $sizeStr\n'
          '📍 *Location:* $locationStr\n\n'
          '📄 Attached Official PDF Brochure Document.';

      await Share.shareXFiles(
        [xFile],
        text: shareText,
        subject: 'Property PDF Brochure — $titleStr',
      );
    } catch (e) {
      // Fallback to URL Sharing if file generation fails
      await _fallbackUrlShare(property, pdfUrl, titleStr, sizeStr, locationStr);
    }
  }

  static Future<void> _fallbackUrlShare(
    PropertyModel property,
    String pdfUrl,
    String titleStr,
    String sizeStr,
    String locationStr,
  ) async {
    final String shareText = '🏡 *Dholera Real Estate — Property Brochure*\n\n'
        '📍 *$titleStr*\n'
        '📐 *Size:* $sizeStr\n'
        '📍 *Location:* $locationStr\n\n'
        '📄 View & Download Official Brochure:\n$pdfUrl';

    final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(shareText, subject: titleStr);
    }
  }
}
