import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../../models/property_model.dart';

/**
 * PDF Brochure & WhatsApp Attachment Sharing Service
 * DHOLERA REAL ESTATE — Cross-Platform File Sharing & Web Download
 */
class PdfShareService {
  /// Shares Property Brochure PDF on WhatsApp & Native Apps
  static Future<void> sharePropertyPdf(BuildContext context, PropertyModel property) async {
    final pdfUrl = '${ApiConfig.baseUrl}${ApiConfig.propertyExportPdf}?id=${property.id}';
    final titleStr = '${property.villageName} Plot (Survey No: ${property.surveyNo})';
    final sizeStr = '${property.area} ${property.areaUnit}';
    final locationStr = '${property.villageName}, Zone: ${property.zone}';

    if (kIsWeb) {
      // Web Environment: Open live PDF brochure directly in browser
      final Uri uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Mobile (Android / iOS): Fetch PDF file bytes & share file attachment via WhatsApp/System Share
    try {
      // Show non-blocking loading toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preparing WhatsApp PDF Brochure for "$titleStr"...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final response = await http.get(Uri.parse(pdfUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final sanitizedTitle = titleStr.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
        final filePath = '${tempDir.path}/Dholera_Property_${property.id}_$sanitizedTitle.html';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final xFile = XFile(filePath, mimeType: 'text/html', name: 'Dholera_Property_${property.id}.html');

        final String shareText = '🏡 *Dholera Real Estate — Property Catalogue*\n\n'
            '📍 *$titleStr*\n'
            '📐 *Size:* $sizeStr\n'
            '📍 *Location:* $locationStr\n\n'
            '📄 Attached Official PDF Brochure for details & photos.';

        await Share.shareXFiles(
          [xFile],
          text: shareText,
          subject: 'Property Brochure — $titleStr',
        );
      } else {
        // Fallback to URL Sharing if PDF fetch fails
        await _fallbackUrlShare(property, pdfUrl, titleStr, sizeStr, locationStr);
      }
    } catch (e) {
      // Fallback to URL sharing
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
