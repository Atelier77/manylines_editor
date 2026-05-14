import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import '../../entities/document/document.dart';
import '../../entities/setting/setting_repository.dart';
import '../../widgets/export_dialog.dart';

class ExportDocumentFeature {
  static void show(BuildContext context, AppDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => ExportDialog(doc: doc),
    );
  }

  static Future<void> exportToPdf(BuildContext context, AppDocument doc) async {
    final isDarkMode = context.read<SettingRepository>().isDarkMode;
    
    final pdf = pw.Document();
    final text = _deltaToPlainText(doc.content);
    final lines = text.split('\n');
    
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    
    final boldFontData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
    final boldTtf = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                doc.name,
                style: pw.TextStyle(
                  font: boldTtf,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: isDarkMode ? PdfColors.white : PdfColors.purple700,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            ...lines.map((line) => pw.Text(
              line,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
              ),
            )),
            pw.SizedBox(height: 40),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                'Создано в Manyllines • ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ),
          ];
        },
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${doc.name}.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Документ экспортирован: ${doc.name}.pdf'),
            backgroundColor: const Color(0xFF16DB93),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка экспорта: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  static Future<void> printDocument(BuildContext context, AppDocument doc) async {
    final pdf = pw.Document();
    final text = _deltaToPlainText(doc.content);
    final lines = text.split('\n');
    
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    
    final boldFontData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
    final boldTtf = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                doc.name,
                style: pw.TextStyle(
                  font: boldTtf,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            ...lines.map((line) => pw.Text(
              line,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
              ),
            )),
          ];
        },
      ),
    );
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static String _deltaToPlainText(Delta delta) {
    final buffer = StringBuffer();
    for (final op in delta.operations) {
      if (op.data is String) {
        buffer.write(op.data as String);
      }
    }
    return buffer.toString();
  }
}