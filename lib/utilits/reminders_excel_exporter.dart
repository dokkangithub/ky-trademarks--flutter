import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';

class RemindersExcelExporter {
  static Future<bool> export({
    required IssueDetailsEntity issue,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['التذكيرات'];
    workbook.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('العنوان'),
      TextCellValue('التفاصيل'),
      TextCellValue('موعد التذكير'),
      TextCellValue('الحالة'),
      TextCellValue('إيميل'),
      TextCellValue('إشعار التطبيق'),
    ]);

    for (final reminder in issue.reminders) {
      sheet.appendRow([
        TextCellValue(reminder.title),
        TextCellValue(reminder.description),
        TextCellValue(reminder.reminderAt),
        TextCellValue(reminder.status),
        TextCellValue(reminder.emailEnabled ? 'نعم' : 'لا'),
        TextCellValue(reminder.notificationEnabled ? 'نعم' : 'لا'),
      ]);
    }

    for (var column = 0; column < 6; column++) {
      sheet.setColumnWidth(column, column == 1 ? 35 : 20);
    }

    final encoded = workbook.encode();
    if (encoded == null) return false;

    final path = await FilePicker.saveFile(
      dialogTitle: 'حفظ ملف التذكيرات',
      fileName: 'reminders_issue_${issue.id}.xlsx',
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      bytes: Uint8List.fromList(encoded),
    );
    return path != null;
  }
}
