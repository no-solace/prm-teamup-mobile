import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/import_class_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_banner.dart';
import 'flow_a_layout.dart';

/// S22: only CSV is supported in Lab 3 (PHAN_CONG, section 5).
class ImportClassScreen extends ConsumerWidget {
  const ImportClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importClassViewModelProvider);
    final model = ref.read(importClassViewModelProvider.notifier);
    final preview = state.preview;
    return FlowAScaffold(
      title: 'Import class list',
      body: ListView(
        padding: kScreenPadding,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preview?.fileName ?? 'Choose a CSV file',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: kSpaceXs),
                Text(
                  state.loading
                      ? 'Reading CSV…'
                      : preview == null
                      ? 'Required: MSSV, full name, class, group, major'
                      : '${state.canImport ? 'Ready to import' : 'Check your file'} · ${preview.rowCount} rows',
                ),
                const SizedBox(height: kSpaceSm),
                AppButton(
                  label: preview == null ? 'Choose CSV' : 'Change file',
                  icon: Icons.upload_file,
                  variant: AppButtonVariant.tonal,
                  loading: state.loading,
                  semanticsLabel: state.loading
                      ? 'Reading CSV file'
                      : 'Choose a CSV class list',
                  onPressed: state.busy ? null : model.chooseFile,
                ),
              ],
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: kSpaceLg),
            ErrorBanner(message: state.error!.message),
          ],
          if (preview != null) ...[
            const SizedBox(height: kSpaceLg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Columns detected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: kSpaceSm),
                  for (final (index, column)
                      in preview.detectedColumns.entries.indexed) ...[
                    if (index > 0) const Divider(),
                    FlowAInfoRow(
                      label: column.key,
                      value: column.value ? 'Detected' : 'Missing',
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: kSpaceLg),
          const FlowANote(
            title: 'Filtered automatically',
            message: 'Students already in a group and teams with 6 members are hidden after import.',
          ),
        ],
      ),
      bottom: AppButton(
        label: preview == null
            ? 'Import students'
            : 'Import ${preview.rowCount} students',
        loading: state.importing,
        semanticsLabel: state.importing
            ? 'Importing students, please wait'
            : state.canImport
            ? 'Import ${preview!.rowCount} students'
            : 'Import unavailable: choose a valid CSV with all five columns',
        onPressed: !state.canImport
            ? null
            : () async {
                final result = await model.importClass();
                if (context.mounted && result != null) {
                  context.go(Routes.importResult);
                }
              },
      ),
    );
  }
}
