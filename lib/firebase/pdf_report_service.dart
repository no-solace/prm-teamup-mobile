import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/class_room.dart';
import '../models/major.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../services/class_service.dart';
import '../services/report_service.dart';

/// Builds a printable roster from the same class streams shown to mentors.
class PdfReportService implements ReportService {
  PdfReportService(this._classes);

  final ClassService _classes;

  @override
  Future<List<int>> buildClassTeamsPdf(String classId) async {
    final room = await _classes.watchClass(classId).first;
    final students = await _classes.watchStudents(classId).first;
    final teams = await _classes.watchTeams(classId).first;
    final byId = {for (final student in students) student.mssv: student};
    final eligible =
        teams.where((team) => team.size >= TeamRules.minMembers).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/BeVietnamPro-Bold.ttf'),
    );
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        header: (context) => _header(room),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Trang ${context.pageNumber}/${context.pagesCount}'),
        ),
        build: (context) => [
          pw.Text(
            'DANH SÁCH NHÓM',
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Lớp: ${room.name}'),
          pw.Text('Số nhóm đủ 5–6 thành viên: ${eligible.length}'),
          pw.SizedBox(height: 16),
          if (eligible.isEmpty) pw.Text('Chưa có nhóm đủ 5–6 thành viên.'),
          for (final team in eligible) ...[
            pw.Header(level: 1, text: '${team.name} (${team.size}/6)'),
            pw.TableHelper.fromTextArray(
              headers: const ['STT', 'MSSV', 'Họ và tên', 'Ngành'],
              data: [
                for (var i = 0; i < team.memberIds.length; i++)
                  _row(i, team, byId),
              ],
              headerStyle: pw.TextStyle(font: bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(color: PdfColors.grey300),
            ),
            pw.SizedBox(height: 12),
          ],
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _header(ClassRoom room) => pw.Container(
    alignment: pw.Alignment.centerRight,
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Text(
      'TEAMUP EXE · ${room.name}',
      style: const pw.TextStyle(fontSize: 9),
    ),
  );

  List<String> _row(int index, Team team, Map<String, Student> byId) {
    final id = team.memberIds[index];
    return [
      '${index + 1}',
      id,
      byId[id]?.fullName ?? 'Chưa có dữ liệu',
      team.majors[index].code,
    ];
  }
}
