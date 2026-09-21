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
      print('Warning: NotoSans fonts could not be loaded.');
    }
    
    final ttf = regularFont ?? pw.Font.helvetica();
    final ttfBold = boldFont ?? pw.Font.helveticaBold();

    pw.ImageProvider? fixedPage7Img;
    pw.ImageProvider? fixedPage8Img;
    pw.ImageProvider? masterPlanImg;
    try {
      final ByteData data7 = await rootBundle.load('assets/images/Images-02.jpg.jpeg');
      fixedPage7Img = pw.MemoryImage(data7.buffer.asUint8List());
    } catch (_) {}
    try {
      final ByteData data8 = await rootBundle.load('assets/images/Images-03.jpg.jpeg');
      fixedPage8Img = pw.MemoryImage(data8.buffer.asUint8List());
      masterPlanImg = fixedPage8Img; // Used in page 3
    } catch (_) {}

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
    
    final pw.PageTheme landscapeTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(30),
    );

    // PAGE 1: COVER
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
            color: PdfColor.fromHex('#041E42'), // Darker blue matching the screenshot
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('DHOLERA', style: pw.TextStyle(font: ttfBold, fontSize: 44, color: PdfColors.white, letterSpacing: 2)),
                  pw.SizedBox(height: 10),
                  pw.Text('INDUSTRIAL PROPOSAL', style: pw.TextStyle(font: ttfBold, fontSize: 32, color: PdfColors.white, letterSpacing: 2)),
                  pw.SizedBox(height: 10),
                  pw.Container(width: 300, height: 2, color: PdfColors.white),
                  pw.SizedBox(height: 20),
                  pw.Text('VILLAGE - $villageName', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColors.white)),
                  pw.SizedBox(height: 20),
                  pw.Text('DHOLERA SIR', style: pw.TextStyle(font: ttfBold, fontSize: 18, color: PdfColors.white)),
                ]
              )
            )
          );
        }
      )
    );

    // PAGE 2: PROPERTY INFORMATION
    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('VILLAGE - $villageName', style: pw.TextStyle(font: ttfBold, fontSize: 28, color: PdfColor.fromHex('#2C3E50'))),
              pw.SizedBox(height: 35),
              
              _buildInfoRow('NEW SURVEY No.', surveyNo, ttf, ttfBold),
              _buildInfoRow('TP', tpStr, ttf, ttfBold),
              _buildInfoRow('FINAL PLOT', fpStr, ttf, ttfBold),
              _buildInfoRow('ROAD TOUCH', roadStr, ttf, ttfBold),
              _buildInfoRow('AREA IN SQ. YARD', areaSqYd, ttf, ttfBold),
              _buildInfoRow('AREA IN METER', areaSqM, ttf, ttfBold),
              _buildInfoRow('READY NA', '', ttf, ttfBold),
              _buildInfoRow('ZONING', zoneStr, ttf, ttfBold),
              _buildInfoRow('ALL TITLE CLEAR', '', ttf, ttfBold),
              
              pw.SizedBox(height: 15),
              pw.Divider(color: PdfColor.fromHex('#BDC3C7')),
              pw.SizedBox(height: 20),
              
              _buildCardsRow(formattedPrice, refStr, propCode, ttf, ttfBold),
            ]
          );
        }
      )
    );

    // PAGE 3: DP LOCATION
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.only(top: 30, bottom: 30, left: 0, right: 0),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                height: 70,
                width: double.infinity,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        color: PdfColors.black,
                        padding: const pw.EdgeInsets.only(left: 40),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text('INDUSTRIAL ZONE - DP\nLOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 22, color: PdfColors.white)),
                      )
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(color: PdfColor.fromHex('#8E44AD'))
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(color: PdfColors.black)
                    )
                  ]
                )
              ),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: masterPlanImg != null ? pw.Image(masterPlanImg, fit: pw.BoxFit.contain) : pw.Container(),
                      )
                    ),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: getImg(0) != null ? pw.Image(getImg(0)!, fit: pw.BoxFit.contain) : pw.Text('DP Location Not Available', style: pw.TextStyle(font: ttf)),
                      )
                    )
                  ]
                )
              )
            ]
          );
        }
      )
    );

    // PAGE 4: OPEN PLOT LOCATION
    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#5E5CA7'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text('OPEN PLOT LOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColors.white)),
              ),
              pw.SizedBox(height: 30),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildBadge('AREA IN SQYD : $areaSqYd', ttfBold),
                          pw.SizedBox(height: 20),
                          _buildBadge('AREA IN METERS : $areaSqM', ttfBold),
                          pw.SizedBox(height: 20),
                          _buildBadge('ROAD TOUCH : $roadStr', ttfBold),
                        ]
                      )
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: getImg(1) != null ? pw.Image(getImg(1)!, fit: pw.BoxFit.contain) : pw.Text('Map Not Available', style: pw.TextStyle(font: ttf))
                    )
                  ]
                )
              )
            ]
          );
        }
      )
    );

    // PAGE 5: NA ORDER
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.only(top: 0, bottom: 30, right: 30, left: 0),
        ),
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 250,
                height: 250,
                padding: const pw.EdgeInsets.only(top: 80, left: 40),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#8E24AA'),
                  borderRadius: const pw.BorderRadius.only(bottomRight: pw.Radius.circular(60)),
                ),
                child: pw.Text('NA ORDER', style: pw.TextStyle(font: ttfBold, fontSize: 28, color: PdfColors.white)),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 30),
                  child: getImg(2) != null ? pw.Image(getImg(2)!, fit: pw.BoxFit.contain) : pw.Center(child: pw.Text('NA Order Not Available', style: pw.TextStyle(font: ttf))),
                )
              )
            ]
          );
        }
      )
    );

    // PAGE 6: ZONING CERTIFICATE
    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#8E24AA'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text('ZONING CERTIFICATE', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColors.white)),
              ),
              pw.SizedBox(height: 30),
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

  static pw.Widget _buildBadge(String text, pw.Font ttfBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#5E5CA7'),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(text, style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.white)),
    );
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
            width: 200,
            child: pw.Text(
              '•   $label',
              style: pw.TextStyle(font: ttf, fontSize: 14, color: PdfColor.fromHex('#2C3E50')),
            )
          ),
          if (value.isNotEmpty)
            pw.Text(
              ' - $value',
              style: pw.TextStyle(font: ttf, fontSize: 14, color: PdfColor.fromHex('#2C3E50')),
            )
        ]
      )
    );
  }
}

