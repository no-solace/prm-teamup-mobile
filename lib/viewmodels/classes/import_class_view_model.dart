import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../../services/class_service.dart';
import '../view_state.dart';
import 'my_classes_view_model.dart';

class PickedClassCsv {
  const PickedClassCsv({required this.name, required this.bytes});
  final String name;
  final List<int> bytes;
}

/// Replace in widget tests; CSV decoding and row validation belong to ClassService.
final classCsvPickerProvider = Provider<Future<PickedClassCsv?> Function()>(
  (ref) => () async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return PickedClassCsv(name: file.name, bytes: bytes);
  },
);

class ImportClassState {
  const ImportClassState({
    this.preview,
    this.loading = false,
    this.importing = false,
    this.error,
    this.result,
  });

  final ImportPreview? preview;
  final bool loading;
  final bool importing;
  final AppError? error;
  final ImportResult? result;

  bool get busy => loading || importing;
  bool get canImport => !busy && preview != null && _validPreview(preview!);
}

bool _validPreview(ImportPreview preview) =>
    preview.rowCount > 0 &&
    preview.rowCount == preview.students.length &&
    preview.className.trim().isNotEmpty &&
    preview.detectedColumns.length == 5 &&
    preview.detectedColumns.values.every((detected) => detected);

/// S22/S23: keeps the preview on write failure so Try again uses the same file.
class ImportClassViewModel extends Notifier<ImportClassState> {
  @override
  ImportClassState build() => const ImportClassState();

  Future<void> chooseFile() async {
    if (state.busy) return;
    final previous = state;
    state = ImportClassState(preview: previous.preview, loading: true);
    try {
      final picked = await ref.read(classCsvPickerProvider)();
      if (!ref.mounted) return;
      if (picked == null) {
        state = previous;
        return;
      }
      await _preview(picked);
    } catch (error) {
      if (ref.mounted) state = ImportClassState(error: toAppError(error));
    }
  }

  Future<void> _preview(PickedClassCsv picked) async {
    if (!picked.name.toLowerCase().endsWith('.csv')) {
      throw const ValidationError(
        'Choose a .csv file with MSSV, full name, class, group and major.',
      );
    }
    if (picked.bytes.isEmpty) {
      throw const ValidationError(
        'This CSV is empty. Choose a file with student rows.',
      );
    }
    final preview = await ref
        .read(classServiceProvider)
        .parseImportFile(fileName: picked.name, bytes: picked.bytes);
    if (!ref.mounted) return;
    if (!_validPreview(preview)) {
      state = ImportClassState(
        preview: preview,
        error: const ValidationError(
          'Check the five required columns and include at least one valid student row.',
        ),
      );
      return;
    }
    state = ImportClassState(preview: preview);
  }

  Future<ImportResult?> importClass() async {
    if (!state.canImport) return null;
    final preview = state.preview!;
    state = ImportClassState(preview: preview, importing: true);
    try {
      final result = await ref.read(classServiceProvider).importClass(preview);
      if (!ref.mounted) return null;
      state = ImportClassState(preview: preview, result: result);
      ref.invalidate(myClassesViewModelProvider);
      return result;
    } catch (error) {
      if (ref.mounted) {
        state = ImportClassState(preview: preview, error: toAppError(error));
      }
      return null;
    }
  }
}

final importClassViewModelProvider =
    NotifierProvider.autoDispose<ImportClassViewModel, ImportClassState>(
      ImportClassViewModel.new,
    );
