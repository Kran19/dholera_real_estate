import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
    } catch (_) {}
    
    final ttf = regularFont ?? pw.Font.helvetica();
    final ttfBold = boldFont ?? pw.Font.helveticaBold();

    pw.ImageProvider? fixedPage7Img;
    pw.ImageProvider? fixedPage8Img;
    pw.ImageProvider? masterPlanImg;
    try {
      final ByteData data7 = await rootBundle.load('assets/images/Images-02.jpg.jpeg');
      fixedPage7Img = pw.MemoryImage(data7.buffer.asUint8List());
      masterPlanImg = fixedPage7Img;
    } catch (_) {}
    try {
      final ByteData data8 = await rootBundle.load('assets/images/Images-03.jpg.jpeg');
      fixedPage8Img = pw.MemoryImage(data8.buffer.asUint8List());
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
    
    final String areaStr = property.area == property.area.truncateToDouble() 
        ? property.area.toInt().toString() 
        : property.area.toString();
        
    final double sqMetersNum = property.area * 0.836127;
    final String sqMetersStr = sqMetersNum.round().toString();

    final pw.PageTheme landscapeTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(40),
    );

    // DYNAMIC IMAGE ALLOCATION ENGINE FOR PROPOSAL SLIDES
    final bool isPachi = villageName.contains('PACHI');
    
    pw.ImageProvider? page2Img = getImg(0) ?? fixedPage7Img;
    pw.ImageProvider? page3Img = getImg(1) ?? getImg(0);
    pw.ImageProvider? page4Img;
    pw.ImageProvider? page5Img;
    pw.ImageProvider? page6Img;

    if (propertyImages.length >= 5) {
      // 5+ images: Full mapping (Primary, DP Map, Open Plot Map, NA Order, Zoning Cert)
      page4Img = getImg(2);
      page5Img = getImg(3);
      page6Img = getImg(4);
    } else if (propertyImages.length == 4 || isPachi) {
      // 4 images (Pachi standard): Primary (0), DP Map (1), NA Order (2), Zoning Cert (3)
      page4Img = getImg(1) ?? getImg(0);
      page5Img = getImg(2);
      page6Img = getImg(3);
    } else if (propertyImages.length == 3) {
      // 3 images: Primary (0), DP Map (1), NA Order (2)
      page4Img = getImg(1) ?? getImg(0);
      page5Img = getImg(2);
      page6Img = null;
    } else {
      page4Img = getImg(1) ?? getImg(0);
      page5Img = null;
      page6Img = null;
    }

    // PAGE 1: COVER
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.zero,
        ),
        build: (pw.Context context) {
          final String proposalType = zoneStr.contains('PROPOSAL') ? zoneStr : '$zoneStr PROPOSAL';
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: PdfColor.fromHex('#041E42'),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('DHOLERA', style: pw.TextStyle(font: ttfBold, fontSize: 60, color: PdfColors.white, letterSpacing: 2)),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.white, width: 2))
                    ),
                    child: pw.Text(proposalType, style: pw.TextStyle(font: ttfBold, fontSize: 40, color: PdfColors.white, letterSpacing: 2)),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text('VILLAGE - $villageName', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColors.white)),
                  pw.SizedBox(height: 10),
                  pw.Text('DHOLERA SIR', style: pw.TextStyle(font: ttfBold, fontSize: 18, color: PdfColors.white)),
                ]
              )
            )
          );
        }
      )
    );

    // PAGE 2: PROPERTY INFORMATION & ACTIVATION MAP
    pdf.addPage(
      pw.Page(
        pageTheme: landscapeTheme,
        build: (pw.Context context) {
          return pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('VILLAGE - $villageName', style: pw.TextStyle(font: ttfBold, fontSize: 30, color: PdfColors.black)),
                    pw.SizedBox(height: 25),
                    
                    if (surveyNo.isNotEmpty) _buildInfoRow('SURVEY / BLOCK No. – $surveyNo', ttf),
                    if (fpStr != '-') _buildInfoRow('FINAL PLOT (FP) No. - $fpStr', ttf),
                    if (tpStr != '-') _buildInfoRow('TOWN PLANNING (TP) - $tpStr', ttf),
                    if (roadStr != '-') _buildInfoRow('ROAD - $roadStr', ttf),
                    _buildInfoRow('AREA IN SQ. YARD – $areaStr SQ. YD', ttf),
                    _buildInfoRow('AREA IN METER – $sqMetersStr SQ. MTR', ttf),
                    _buildInfoRow('READY NA', ttf),
                    _buildInfoRow('ZONING - $zoneStr', ttf),
                    pw.SizedBox(height: 10),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 18),
                      child: pw.Text('ALL TITLE CLEAR', style: pw.TextStyle(font: ttfBold, fontSize: 18, color: PdfColors.black))
                    ),
                  ]
                )
              ),
              pw.Expanded(
                flex: 5,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: page2Img != null
                      ? pw.Image(page2Img, fit: pw.BoxFit.contain)
                      : pw.Container(),
                )
              )
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
          margin: const pw.EdgeInsets.symmetric(vertical: 40),
        ),
        build: (pw.Context context) {
          final String dpHeaderTitle = '$zoneStr ZONE – DP';
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 80,
                width: double.infinity,
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 420,
                      color: PdfColors.black,
                      padding: const pw.EdgeInsets.only(left: 40, top: 15, bottom: 15),
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(dpHeaderTitle, style: pw.TextStyle(font: ttfBold, fontSize: 26, color: PdfColors.white)),
                          pw.Text('LOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 26, color: PdfColors.white)),
                        ]
                      )
                    ),
                    pw.Expanded(
                      child: pw.Container(color: PdfColor.fromHex('#8E24AA'))
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
                        child: page3Img != null
                            ? pw.Image(page3Img, fit: pw.BoxFit.contain)
                            : pw.Center(child: pw.Text('DP Location Not Available', style: pw.TextStyle(font: ttf))),
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
                padding: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#5E5CA7'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text('OPEN PLOT LOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 28, color: PdfColors.white)),
              ),
              pw.SizedBox(height: 25),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (surveyNo.isNotEmpty) ...[
                            _buildBadge('SURVEY No. : $surveyNo', ttfBold),
                            pw.SizedBox(height: 12),
                          ],
                          if (fpStr != '-') ...[
                            _buildBadge('FINAL PLOT (FP) : $fpStr', ttfBold),
                            pw.SizedBox(height: 12),
                          ],
                          if (tpStr != '-') ...[
                            _buildBadge('TP No. : $tpStr', ttfBold),
                            pw.SizedBox(height: 12),
                          ],
                          _buildBadge('AREA IN SQYD : $areaStr', ttfBold),
                          pw.SizedBox(height: 12),
                          _buildBadge('AREA IN METERS : $sqMetersStr', ttfBold),
                          pw.SizedBox(height: 12),
                          _buildBadge('ROAD : $roadStr', ttfBold),
                        ]
                      )
                    ),
                    pw.Expanded(
                      flex: 6,
                      child: page4Img != null
                          ? pw.Image(page4Img, fit: pw.BoxFit.contain)
                          : pw.Center(child: pw.Text('Map Not Available', style: pw.TextStyle(font: ttf)))
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
          margin: const pw.EdgeInsets.only(top: 0, bottom: 40, right: 40, left: 0),
        ),
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                width: 300,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#8E24AA'),
                  borderRadius: const pw.BorderRadius.only(bottomRight: pw.Radius.circular(250)),
                ),
                child: pw.Center(
                  child: pw.Text('NA ORDER', style: pw.TextStyle(font: ttfBold, fontSize: 40, color: PdfColors.white)),
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 40, left: 40),
                  child: page5Img != null
                      ? pw.Image(page5Img, fit: pw.BoxFit.contain)
                      : pw.Center(child: pw.Text('NA Order Not Available', style: pw.TextStyle(font: ttf))),
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
                padding: const pw.EdgeInsets.symmetric(horizontal: 70, vertical: 20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#8E24AA'),
                  borderRadius: pw.BorderRadius.circular(15),
                ),
                child: pw.Text('ZONING CERTIFICATE', style: pw.TextStyle(font: ttfBold, fontSize: 36, color: PdfColors.white)),
              ),
              pw.SizedBox(height: 30),
              pw.Expanded(
                child: pw.Center(
                  child: page6Img != null
                      ? pw.Image(page6Img, fit: pw.BoxFit.contain)
                      : pw.Text('Zoning Certificate Not Available', style: pw.TextStyle(font: ttf)),
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

    // PAGE 9+: ADDITIONAL PROPERTY SITE PHOTOS (for images beyond 5th image)
    if (propertyImages.length > 5) {
      for (int i = 5; i < propertyImages.length; i++) {
        final currentImg = propertyImages[i];
        pdf.addPage(
          pw.Page(
            pageTheme: landscapeTheme,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#041E42'),
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Text('SITE PHOTO ${i - 4}', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColors.white)),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(currentImg, fit: pw.BoxFit.contain),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  static pw.Widget _buildBadge(String text, pw.Font ttfBold) {
    return pw.Container(
      width: 280,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#5E5CA7'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(text, style: pw.TextStyle(font: ttfBold, fontSize: 13, color: PdfColors.white)),
    );
  }

  static pw.Widget _buildInfoRow(String text, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('•   ', style: pw.TextStyle(font: ttf, fontSize: 20, color: PdfColors.black)),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: ttf, fontSize: 18, color: PdfColors.black),
            )
          )
        ]
      )
    );
  }
}
