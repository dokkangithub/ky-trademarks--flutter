import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/StringManager.dart';
import 'package:kyuser/utilits/reminders_excel_exporter.dart';

class RemindersTable extends StatefulWidget {
  final IssueDetailsEntity issue;

  const RemindersTable({super.key, required this.issue});

  @override
  State<RemindersTable> createState() => _RemindersTableState();
}

class _RemindersTableState extends State<RemindersTable> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final saved = await RemindersExcelExporter.export(issue: widget.issue);
      if (!mounted || !saved) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ ملف التذكيرات بنجاح')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ ملف التذكيرات'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminders = widget.issue.reminders;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined,
                  color: Colors.orange.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'التذكيرات',
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              if (reminders.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _exporting ? null : _export,
                  icon: _exporting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  label: const Text('تحميل Excel'),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (reminders.isEmpty)
            const Center(child: Text('لا توجد تذكيرات لهذه القضية'))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  ColorManager.primary.withValues(alpha: .08),
                ),
                columns: const [
                  DataColumn(label: Text('العنوان')),
                  DataColumn(label: Text('التفاصيل')),
                  DataColumn(label: Text('الموعد')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('قنوات الإرسال')),
                ],
                rows: reminders.map(_row).toList(),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _row(ReminderEntity reminder) {
    final channels = <String>[
      if (reminder.emailEnabled) 'الإيميل',
      if (reminder.notificationEnabled) 'التطبيق',
    ].join(' + ');
    return DataRow(cells: [
      DataCell(Text(reminder.title.isEmpty ? 'تذكير' : reminder.title)),
      DataCell(SizedBox(
        width: 220,
        child: Text(reminder.description.isEmpty ? '—' : reminder.description),
      )),
      DataCell(Text(_date(reminder.reminderAt))),
      DataCell(Text(reminder.status.isEmpty
          ? _derivedStatus(reminder)
          : reminder.status)),
      DataCell(Text(channels.isEmpty ? '—' : channels)),
    ]);
  }

  String _date(String value) {
    final date = DateTime.tryParse(value);
    return date == null
        ? (value.isEmpty ? '—' : value)
        : DateFormat('dd/MM/yyyy - hh:mm a').format(date.toLocal());
  }

  String _derivedStatus(ReminderEntity reminder) {
    final date = DateTime.tryParse(reminder.reminderAt);
    return date != null && date.isBefore(DateTime.now()) ? 'تم الموعد' : 'قادم';
  }
}
