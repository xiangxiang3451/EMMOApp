import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmo/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// 表情符号到英文描述的映射
const Map<String, String> emojiToText = {
  "😊": "Happy",
  "😔": "Sad",
  "😡": "Angry",
  "😱": "Fearful",
  "😴": "Tired",
  "😂": "Laughing",
  "😢": "Crying",
  "😍": "In Love",
  "🤔": "Thinking",
  "😎": "Cool",
  "🙃": "Upside Down",
  "🥳": "Celebrating"
};

String replaceEmojiWithText(String expression) {
  return emojiToText[expression] ?? expression;
}

class ExportPdfScreen extends StatefulWidget {
  @override
  _ExportPdfScreenState createState() => _ExportPdfScreenState();
}

class _ExportPdfScreenState extends State<ExportPdfScreen> {
  List<Map<String, dynamic>> records = [];

  Future<void> _getRecords() async {
    String? userId = AuthenticationService.currentUserEmail;

    try {
      final firestore = FirebaseFirestore.instance;

      final snapshot = await firestore
          .collection('record')
          .where('userId', isEqualTo: userId)
          .orderBy('time', descending: true)
          .get();

      setState(() {
        records = snapshot.docs.map((doc) {
          return {
            'expression': doc['expression'],
            'date': doc['date'],
            'address': doc['address'],
            'thoughts': doc['thoughts'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching records: $e')),
      );
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Text(
          'User Mood Records',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        footer: (pw.Context context) => pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
        build: (pw.Context context) => [
          ...records.map((record) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Expression: ${replaceEmojiWithText(record['expression'])}',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Date: ${record['date']}', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Address: ${record['address']}', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Thoughts: ${record['thoughts']}', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/user_mood_records.pdf");
    await file.writeAsBytes(await pdf.save());

    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generated successfully!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _getRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Mood Records')),
      body: Center(
        child: ElevatedButton(
          onPressed: _generatePDF,
          child: const Text('Export as PDF'),
        ),
      ),
    );
  }
}
