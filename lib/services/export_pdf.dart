import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmo/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  @override
  void initState() {
    super.initState();
    _getRecords();
  }

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

  List<PieChartSectionData> _generatePieChartSections() {
    Map<String, int> moodCount = {
      for (var mood in emojiToText.values) mood: 0,
    };

    for (var record in records) {
      String moodText = replaceEmojiWithText(record['expression']);
      if (moodCount.containsKey(moodText)) {
        moodCount[moodText] = moodCount[moodText]! + 1;
      }
    }

    return moodCount.entries
        .where((entry) => entry.value > 0)
        .map((entry) => PieChartSectionData(
              value: entry.value.toDouble(),
              title: entry.key,
              color: _getColorForMood(entry.key),
              radius: 50,
              titleStyle: const TextStyle(fontSize: 0), // 不显示文字
            ))
        .toList();
  }

  Color _getColorForMood(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.yellow;
      case 'Sad':
        return Colors.blue;
      case 'Angry':
        return Colors.red;
      case 'Fearful':
        return Colors.purple;
      case 'Tired':
        return Colors.grey;
      case 'Laughing':
        return Colors.orange;
      case 'Crying':
        return Colors.lightBlue;
      case 'In Love':
        return Colors.pink;
      case 'Thinking':
        return Colors.green;
      case 'Cool':
        return Colors.teal;
      case 'Upside Down':
        return Colors.indigo;
      case 'Celebrating':
        return Colors.amber;
      default:
        return Colors.black;
    }
  }

  void _showPieChartDialog(BuildContext context) {
    final sections = _generatePieChartSections();
    final total = sections.fold<double>(0, (sum, item) => sum + item.value);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mood Distribution'),
          content: SizedBox(
            height: 400,
            width: 400,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: sections.map((s) => s.copyWith(title: '')).toList(),
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: ListView(
                    children: sections.map((s) {
                      final percentage = (s.value / total * 100).toStringAsFixed(1);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: s.color,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${s.title} - $percentage%',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Mood Records')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _generatePDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export as PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showPieChartDialog(context),
              icon: const Icon(Icons.pie_chart),
              label: const Text('Export as Pie Chart'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
