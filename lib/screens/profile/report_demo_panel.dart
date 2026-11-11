import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../models/class_room.dart';
import '../../models/report.dart';
import '../../services/app_error.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/profile/report_demo_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';

/// S6 Firebase demo. Export, cloud upload, upload progress and saved reports.
class ReportDemoPanel extends ConsumerStatefulWidget {
  const ReportDemoPanel({super.key});

  @override
  ConsumerState<ReportDemoPanel> createState() => _ReportDemoPanelState();
}

class _ReportDemoPanelState extends ConsumerState<ReportDemoPanel> {
  String? _selectedClass;
  bool _busy = false;
  double? _progress;
  String? _status;

  /// Lab 3 rubric: the download URL of the uploaded file must be visible.
  String? _downloadUrl;

  void _feedback(String message) {
    if (mounted) setState(() => _status = message);
  }

  Future<void> _export(String classId) async {
    setState(() {
      _busy = true;
      _progress = null;
      _status = null;
      _downloadUrl = null;
    });
    try {
      final actions = ref.read(reportDemoActionsProvider);
      final built = await actions.buildPdf(classId);
      Report? saved;
      await for (final event in actions.upload(
        classId,
        built.bytes,
        teamCount: built.teamCount,
      )) {
        if (!mounted) return;
        if (event is UploadProgress) {
          setState(() => _progress = event.fraction);
        }
        if (event is UploadDone) saved = event.report;
      }
      if (saved == null) {
        throw const UnknownError('Report upload was interrupted');
      }
      _feedback(
        'Uploaded ${saved.sizeKb} KB to ${saved.storagePath}. '
        'Opening the PDF share dialog.',
      );
      setState(() => _downloadUrl = saved!.downloadUrl);
      await Printing.sharePdf(
        bytes: Uint8List.fromList(built.bytes),
        filename: 'teamup_$classId.pdf',
      );
    } catch (error) {
      _feedback(toAppError(error).message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareSaved(Report report) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final bytes = await ref.read(reportDemoActionsProvider).download(report);
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'teamup_${report.classId}_${report.id}.pdf',
      );
    } catch (error) {
      _feedback(toAppError(error).message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(reportClassesProvider);
    final reports = ref.watch(mentorReportsProvider);
    final available = classes.value ?? const <ClassRoom>[];
    final selectedId = available.any((c) => c.id == _selectedClass)
        ? _selectedClass
        : null;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export PDF to Firebase Storage', style: text.titleMedium),
        const SizedBox(height: kSpaceMd),
        if (classes.isLoading) const LinearProgressIndicator(),
        if (classes.hasError) Text('Could not load classes: ${classes.error}'),
        DropdownButtonFormField<String>(
          key: ValueKey(selectedId),
          initialValue: selectedId,
          decoration: const InputDecoration(labelText: 'Select class'),
          items: [
            for (final room in available)
              DropdownMenuItem(value: room.id, child: Text(room.name)),
          ],
          onChanged: _busy ? null : (id) => setState(() => _selectedClass = id),
        ),
        const SizedBox(height: kSpaceMd),
        AppButton(
          label: 'Generate and upload PDF',
          icon: Icons.picture_as_pdf_outlined,
          loading: _busy,
          onPressed: selectedId == null || _busy
              ? null
              : () => _export(selectedId),
        ),
        if (_progress != null) ...[
          const SizedBox(height: kSpaceSm),
          LinearProgressIndicator(value: _progress),
          Text('${(_progress! * 100).round()}% uploaded'),
        ],
        if (_status != null) ...[
          const SizedBox(height: kSpaceSm),
          Text(_status!, style: text.bodyMedium),
        ],
        if (_downloadUrl != null) ...[
          const SizedBox(height: kSpaceSm),
          Text('Download URL', style: text.titleSmall),
          SelectableText(
            _downloadUrl!,
            style: text.bodySmall,
            semanticsLabel: 'Download URL of the uploaded report',
          ),
        ],
        const SizedBox(height: kSpaceMd),
        Text('Saved reports', style: text.titleMedium),
        if (reports.isLoading) const LinearProgressIndicator(),
        if (reports.hasError) Text('Could not load reports: ${reports.error}'),
        if (reports.value?.isEmpty ?? false)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: kSpaceSm),
            child: Text('No reports uploaded yet.'),
          ),
        for (final report in reports.value ?? const <Report>[])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: Text(
              available
                      .where((c) => c.id == report.classId)
                      .map((c) => c.name)
                      .firstOrNull ??
                  report.classId,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${report.sizeKb} KB · ${report.createdAt.toLocal()}'),
                Text(
                  report.storagePath,
                  style: text.bodySmall,
                  semanticsLabel: 'Storage path ${report.storagePath}',
                ),
                SelectableText(
                  report.downloadUrl,
                  style: text.bodySmall,
                  semanticsLabel:
                      'Download URL of ${report.storagePath}',
                ),
              ],
            ),
            trailing: IconButton(
              tooltip: 'Share saved PDF',
              onPressed: _busy ? null : () => _shareSaved(report),
              icon: const Icon(Icons.ios_share_outlined),
            ),
          ),
      ],
    );
  }
}
