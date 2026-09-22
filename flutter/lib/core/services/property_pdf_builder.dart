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
      masterPlanImg = fixedPage7Img; // Used in page 3
    } catch (_) {}
    try {
      final ByteData data8 = await rootBundle.load('assets/images/Images-03.jpg.jpeg');
      fixedPage8Img = pw.MemoryImage(data8.buffer.asUint8List());
    } catch (_) {}

    final List<pw.ImageProvider?> propertyImages = List.filled(5, null);
    
    for (var img in property.images) {
      if (img.imageUrl.isNotEmpty && img.sortOrder >= 1 && img.sortOrder <= 5) {
        try {
          final res = await http.get(Uri.parse(img.imageUrl)).timeout(const Duration(seconds: 8));
          if (res.statusCode == 200) {
            propertyImages[img.sortOrder - 1] = pw.MemoryImage(res.bodyBytes);
          }
        } catch (_) {}
      }
    }

    // Fallback for older properties where primaryImage was the DP map
    if (propertyImages[0] == null && property.primaryImage != null && property.primaryImage!.isNotEmpty) {
       try {
        final res = await http.get(Uri.parse(property.primaryImage!)).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) propertyImages[0] = pw.MemoryImage(res.bodyBytes);
      } catch (_) {}
    }
    
    pw.ImageProvider? getImg(int index) {
      if (index >= 0 && index < propertyImages.length) return propertyImages[index];
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
            color: PdfColor.fromHex('#041E42'), // Dark blue
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
                    child: pw.Text('INDUSTRIAL PROPOSAL', style: pw.TextStyle(font: ttfBold, fontSize: 40, color: PdfColors.white, letterSpacing: 2)),
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

    // PAGE 2: PROPERTY INFORMATION
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
                    pw.Text('VILLAGE - $villageName', style: pw.TextStyle(font: ttfBold, fontSize: 32, color: PdfColors.black)),
                    pw.SizedBox(height: 40),
                    
                    _buildInfoRow('NEW SURVEY No. – $surveyNo', ttf),
                    if (fpStr != '-') _buildInfoRow('OLD SURVEY No. - $fpStr', ttf),
                    _buildInfoRow('TP $tpStr', ttf),
                    _buildInfoRow('TP ROAD - $roadStr', ttf),
                    _buildInfoRow('AREA IN SQ. YARD – $areaStr', ttf),
                    _buildInfoRow('AREA IN METER – $sqMetersStr', ttf),
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
                child: pw.Container()
              )
            ]
          );
        }
      )
    );

    // PAGE 3: DP LOCATION
    if (getImg(0) != null) {
      pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.symmetric(vertical: 40),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 80,
                width: double.infinity,
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 400,
                      color: PdfColors.black,
                      padding: const pw.EdgeInsets.only(left: 60, top: 15, bottom: 15),
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('INDUSTRIAL ZONE – DP', style: pw.TextStyle(font: ttfBold, fontSize: 28, color: PdfColors.white)),
                          pw.Text('LOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 28, color: PdfColors.white)),
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
                        child: masterPlanImg != null ? pw.Image(masterPlanImg!, fit: pw.BoxFit.contain) : pw.Container(),
                      )
                    ),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: getImg(0) != null ? pw.Image(getImg(0)!, fit: pw.BoxFit.contain) : pw.Center(child: pw.Text('DP Location Not Available', style: pw.TextStyle(font: ttf))),
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
    }

    // PAGE 4: OPEN PLOT LOCATION
    if (getImg(1) != null) {
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
                  color: PdfColor.fromHex('#5E5CA7'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text('OPEN PLOT LOCATION', style: pw.TextStyle(font: ttfBold, fontSize: 28, color: PdfColors.white)),
              ),
              pw.SizedBox(height: 40),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildBadge('AREA IN SQYD : $areaStr', ttfBold),
                          pw.SizedBox(height: 25),
                          _buildBadge('AREA IN METERS : $sqMetersStr', ttfBold),
                          pw.SizedBox(height: 25),
                          _buildBadge('TP ROAD : $roadStr', ttfBold),
                        ]
                      )
                    ),
                    pw.Expanded(
                      flex: 6,
                      child: getImg(1) != null ? pw.Image(getImg(1)!, fit: pw.BoxFit.contain) : pw.Center(child: pw.Text('Map Not Available', style: pw.TextStyle(font: ttf)))
                    )
                  ]
                )
              )
            ]
          );
        }
      )
    );
    }

    // PAGE 5: NA ORDER
    if (getImg(2) != null) {
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
                  child: getImg(2) != null ? pw.Image(getImg(2)!, fit: pw.BoxFit.contain) : pw.Center(child: pw.Text('NA Order Not Available', style: pw.TextStyle(font: ttf))),
                )
              )
            ]
          );
        }
      )
    );
    }

    // PAGE 6: ZONING CERTIFICATE
    if (getImg(3) != null || getImg(4) != null || getImg(5) != null) {
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
                child: Builder(
                  builder: (context) {
                    List<pw.Widget> zoningImages = [];
                    if (getImg(3) != null) zoningImages.add(pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Image(getImg(3)!, fit: pw.BoxFit.contain)));
                    if (getImg(4) != null) zoningImages.add(pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Image(getImg(4)!, fit: pw.BoxFit.contain)));
                    if (getImg(5) != null) zoningImages.add(pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Image(getImg(5)!, fit: pw.BoxFit.contain)));
                    
                    if (zoningImages.isEmpty) {
                      return pw.Center(child: pw.Text('Zoning Certificate Not Available', style: pw.TextStyle(font: ttf)));
                    } else if (zoningImages.length == 1) {
                      return pw.Center(child: zoningImages.first);
                    } else {
                      return pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: zoningImages.map((img) => pw.Expanded(child: pw.Center(child: img))).toList(),
                      );
                    }
                  },
                )
              )
            ]
          );
        }
      )
    );
    }

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
      width: 300,
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#5E5CA7'),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(text, style: pw.TextStyle(font: ttfBold, fontSize: 16, color: PdfColors.white)),
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
