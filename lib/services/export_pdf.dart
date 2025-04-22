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

// 将表情符号替换为对应的英文描述
String replaceEmojiWithText(String expression) {
  return emojiToText[expression] ?? expression; // 如果表情符号没有对应的文本，返回原表情符号
}

class ExportPdfScreen extends StatefulWidget {
  @override
  _ExportPdfScreenState createState() => _ExportPdfScreenState();
}

class _ExportPdfScreenState extends State<ExportPdfScreen> {
  List<Map<String, dynamic>> records = [];

  // 获取记录
  Future<void> _getRecords() async {
    String? userId = AuthenticationService.currentUserEmail;

    try {
      final firestore = FirebaseFirestore.instance;

      final snapshot = await firestore
          .collection('record')
          .where('userId', isEqualTo: userId)
          .orderBy('time', descending: true) // 确保按时间倒序查询
          .get();

      setState(() {
        records = snapshot.docs.map((doc) {
          return {
            'expression': doc['expression'], // 表情
            'date': doc['date'], // 日期
            'address': doc['address'], // 地址
            'thoughts': doc['thoughts'], // 备注
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

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('User Mood Records', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            ...records.map((record) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Expression: ${replaceEmojiWithText(record['expression'])}', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text('Date: ${record['date']}', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text('Address: ${record['address']}', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text('Thoughts: ${record['thoughts']}', style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 10),
                ],
              );
            }),
          ],
        );
      },
    ));

    // 保存 PDF 文件
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/user_mood_records.pdf");
    await file.writeAsBytes(await pdf.save());

    // 打开 PDF 文件
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generated successfully!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _getRecords();  // 加载记录
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
