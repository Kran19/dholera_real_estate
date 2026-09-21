import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/property_model.dart';

class PropertyPdfBuilder {
  static Future<Uint8List> buildPdf(PropertyModel property) async {
    final pdf = pw.Document();
    
    pw.Font? regularFont;
    pw.Font? boldFont;
    try {
      final ByteData regularData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      regularFont = pw.Font.ttf(regularData);
      
      final ByteData boldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      boldFont = pw.Font.ttf(boldData);
    } catch (e) {
      print('Warning: NotoSans fonts could not be loaded. Rs symbol might fail.');
    }
    
    final ttf = regularFont ?? pw.Font.helvetica();
    final ttfBold = boldFont ?? pw.Font.helveticaBold();

    pw.ImageProvider? fixedPage7Img;
    pw.ImageProvider? fixedPage8Img;
    try {
      final ByteData data7 = await rootBundle.load('assets/images/page7_dmic.jpg');
      fixedPage7Img = pw.MemoryImage(data7.buffer.asUint8List());
    } catch (_) {
      print('Warning: page7_dmic.jpg not found in assets/images/');
    }
    try {
      final ByteData data8 = await rootBundle.load('assets/images/page8_masterplan.jpg');
      fixedPage8Img = pw.MemoryImage(data8.buffer.asUint8List());
    } catch (_) {
      print('Warning: page8_masterplan.jpg not found in assets/images/');
    }

    final List<pw.ImageProvider> propertyImages = [];
    if (property.primaryImage != null && property.primaryImage!.isNotEmpty) {
       try {
        final res = await http.get(Uri.parse(property.primaryImage!)).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) propertyImages.add(pw.MemoryImage(res.bodyBytes));
      } catch (_) {}
    }
    
    for (var img in property.images) {
      if (img.imageUrl.isNotEmpty && property.primaryImage != img.imageUrl) {
        try {
          final res = await http.get(Uri.parse(img.imageUrl)).timeout(const Duration(seconds: 8));
          if (res.statusCode == 200) propertyImages.add(pw.MemoryImage(res.bodyBytes));
        } catch (_) {}
      }
    }
    
    pw.ImageProvider? getImg(int index) {
      if (index < propertyImages.length) return propertyImages[index];
      return null;
    }

    final String villageName = property.villageName.toUpperCase();
    final String surveyNo = property.surveyNo;
    final String zoneStr = property.zone.isNotEmpty ? property.zone.toUpperCase() : 'INDUSTRIAL';
    final String tpStr = (property.tp != null && property.tp!.isNotEmpty) ? property.tp! : '-';
    final String fpStr = (property.fp != null && property.fp!.isNotEmpty) ? property.fp! : '-';
    final String roadStr = property.road.isNotEmpty ? property.road : '-';
    final String areaSqYd = '${property.area} ${property.areaUnit}';
    final double sqMetersNum = property.area * 0.836127;
    final String areaSqM = '${sqMetersNum.toStringAsFixed(0)} SQ. METER';

    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ', decimalDigits: 0);
    String formattedPrice = '-';
    if (property.landingPrice != null && property.landingPrice!.isNotEmpty) {
      final priceNum = double.tryParse(property.landingPrice!.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (priceNum != null) {
        formattedPrice = currencyFormat.format(priceNum).replaceAll('Rs ', '\u20B9 ');
      } else {
        formattedPrice = '\u20B9 ${property.landingPrice}';
      }
    }
    
    final String refStr = (property.reference != null && property.reference!.isNotEmpty) ? property.reference! : '-';
    final String propCode = '#DRE-${property.id}';
    
    print('PDF PIPELINE VERIFICATION:');
    print('Property Code: $propCode');
    print('Landing Price: $formattedPrice');
    print('Reference: $refStr');
    
    final pw.PageTheme landscapeTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(30),
    );

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.zero,
        ),
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: PdfColor.fromHex('#2C3E50'),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('INDUSTRIAL PROPOSAL', style: pw.TextStyle(font: ttfBold, fontSize: 44, color: PdfColors.white, letterSpacing: 2)),
                  pw.SizedBox(height: 50),
                  pw.Text('DHOLERA', style: pw.TextStyle(font: ttfBold, fontSize: 36, color: PdfColor.fromHex('#F1C40F'), letterSpacing: 5)),
                  pw.SizedBox(height: 25),
                  pw.Text('VILLAGE - $villageName', style: pw.TextStyle(font: ttfBold, fontSize: 32, color: PdfColors.white)),
                  pw.SizedBox(height: 80),
                  pw.Text('DHOLERA SIR', style: pw.TextStyle(font: ttfBold, fontSize: 26, color: PdfColors.white, letterSpacing: 4)),
                ]
              )
            )
          );
        }
      )
    );

    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PROPERTY / LAND INFORMATION', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColor.fromHex('#2C3E50'))),
              pw.SizedBox(height: 10),
              
              _buildInfoRow('VILLAGE', villageName, ttf, ttfBold),
              _buildInfoRow('NEW SURVEY No.', surveyNo, ttf, ttfBold),
              _buildInfoRow('TP', tpStr, ttf, ttfBold),
              _buildInfoRow('FINAL PLOT', fpStr, ttf, ttfBold),
              _buildInfoRow('ROAD TOUCH', roadStr, ttf, ttfBold),
              _buildInfoRow('AREA IN SQ. YARD', areaSqYd, ttf, ttfBold),
              _buildInfoRow('AREA IN METER', areaSqM, ttf, ttfBold),
              _buildInfoRow('ZONING', zoneStr, ttf, ttfBold),
              
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColor.fromHex('#BDC3C7')),
              pw.SizedBox(height: 10),
              
              pw.SizedBox(height: 20),
              _buildCardsRow(formattedPrice, refStr, propCode, ttf, ttfBold),
            ]
          );
        }
      )
    );

    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INDUSTRIAL ZONE – DP LOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColor.fromHex('#2C3E50'))),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Center(
                  child: getImg(0) != null 
                    ? pw.Image(getImg(0)!, fit: pw.BoxFit.contain)
                    : pw.Text('DP Location Map Not Available', style: pw.TextStyle(font: ttf))
                )
              )
            ]
          );
        }
      )
    );

    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('OPEN PLOT LOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColor.fromHex('#2C3E50'))),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text('AREA IN SQYD : $areaSqYd', style: pw.TextStyle(font: ttfBold, fontSize: 14)),
                  pw.Text('AREA IN METERS : $areaSqM', style: pw.TextStyle(font: ttfBold, fontSize: 14)),
                  pw.Text('ROAD TOUCH : $roadStr', style: pw.TextStyle(font: ttfBold, fontSize: 14)),
                ]
              ),
              pw.SizedBox(height: 25),
              pw.Expanded(
                child: pw.Center(
                  child: getImg(1) != null 
                    ? pw.Image(getImg(1)!, fit: pw.BoxFit.contain)
                    : pw.Text('Open Plot Map Not Available', style: pw.TextStyle(font: ttf))
                )
              )
            ]
          );
        }
      )
    );

    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('NA ORDER', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColor.fromHex('#2C3E50'))),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Center(
                  child: getImg(2) != null 
                    ? pw.Image(getImg(2)!, fit: pw.BoxFit.contain)
                    : pw.Text('NA Order Document Not Available', style: pw.TextStyle(font: ttf))
                )
              )
            ]
          );
        }
      )
    );

    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ZONING CERTIFICATE', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColor.fromHex('#2C3E50'))),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Center(
                  child: getImg(3) != null 
                    ? pw.Image(getImg(3)!, fit: pw.BoxFit.contain)
                    : pw.Text('Zoning Certificate Not Available', style: pw.TextStyle(font: ttf))
                )
              )
            ]
          );
        }
      )
    );

    // PAGE 7: FIXED - Smart Industrial Townships under DMIC
    if (fixedPage7Img != null) {
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: pw.EdgeInsets.zero,
          ),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(fixedPage7Img!, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    // PAGE 8: FIXED - Master Plan Dholera SIR
    if (fixedPage8Img != null) {
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: pw.EdgeInsets.zero,
          ),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(fixedPage8Img!, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildCardsRow(String price, String ref, String code, pw.Font ttf, pw.Font ttfBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildCard('LANDING PRICE', price, '\u20B9', ttf, ttfBold),
        pw.SizedBox(width: 15),
        _buildCard('REFERENCE', ref, 'R', ttf, ttfBold),
        pw.SizedBox(width: 15),
        _buildCard('PROPERTY CODE', code, '#', ttf, ttfBold),
      ]
    );
  }

  static pw.Widget _buildCard(String title, String value, String iconText, pw.Font ttf, pw.Font ttfBold) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F4F9FF'),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('#E1EFFF'), width: 1.5),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 28,
              height: 28,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0F2A4A'),
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  iconText,
                  style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.white),
                )
              )
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(font: ttfBold, fontSize: 10, color: PdfColor.fromHex('#29528A')),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    value,
                    style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColor.fromHex('#0F2A4A')),
                    maxLines: 1,
                  ),
                ]
              )
            )
          ]
        )
      )
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font ttf, pw.Font ttfBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 250,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColor.fromHex('#7F8C8D')),
            )
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColor.fromHex('#2C3E50')),
            )
          )
        ]
      )
    );
  }
}




