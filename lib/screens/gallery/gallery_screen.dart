import 'package:flutter/material.dart';

import '../../models/major.dart';
import '../../models/proposal.dart';
import '../../models/student.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/fit_chip.dart';
import '../../widgets/major_filter_chips.dart';
import '../../widgets/major_slot.dart';
import '../../widgets/stat_triple.dart';
import '../../widgets/status_view.dart';
import '../../widgets/student_row.dart';

/// Debug gallery of the 12 shared widgets (D9). Only routed in main_fake.dart.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Major? _filter;
  bool _checked = true;

  static const _student = Student(mssv: 'SE000001', fullName: 'Minh Anh', major: Major.gd, classId: 'g', semester: 'S5');

  Widget _section(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: kSpaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: kSpaceSm),
          child,
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget gallery')),
      body: ListView(
        padding: kScreenPadding,
        children: [
          _section('AppButton', Column(children: [
            AppButton(label: 'Match with AI', onPressed: () {}),
            const SizedBox(height: kSpaceSm),
            AppButton(label: 'Tonal', variant: AppButtonVariant.tonal, onPressed: () {}),
            const SizedBox(height: kSpaceSm),
            const AppButton(label: 'Loading', loading: true, onPressed: null),
            const SizedBox(height: kSpaceSm),
            AppButton(label: 'Discard', variant: AppButtonVariant.destructive, onPressed: () {}),
            AppButton(label: 'Text button', variant: AppButtonVariant.text, onPressed: () {}),
          ])),
          _section('AppTextField', const Column(children: [
            AppTextField(label: 'Search students', prefixIcon: Icons.search),
            SizedBox(height: kSpaceSm),
            AppTextField(label: 'Email', errorText: 'Enter a valid email'),
          ])),
          _section('AppCard', AppCard(onTap: () {}, child: const Text('Tutor Match, 5 of 6'))),
          _section('MajorSlotRow (40 / 48)', const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MajorSlotRow(members: [Major.se, Major.se, Major.ai], proposed: [Major.gd]),
            SizedBox(height: kSpaceSm),
            MajorSlotRow(members: [Major.se, Major.mkt, Major.ai, Major.gd, Major.se], size: kMajorSlotLarge),
          ])),
          _section('FitChip / TagChip', const Wrap(spacing: kSpaceSm, children: [
            FitChip(fit: ProposalFit.strong),
            FitChip(fit: ProposalFit.good),
            TagChip(label: 'Added by you', icon: Icons.person_add_alt),
          ])),
          _section('MajorFilterChips', MajorFilterChips(selected: _filter, onSelected: (m) => setState(() => _filter = m))),
          _section('StudentRow', Column(children: [
            StudentRow(student: _student, onTap: () {}),
            StudentRow(student: _student, checked: _checked, onChecked: (v) => setState(() => _checked = v)),
            const StudentRow(student: _student, locked: true),
          ])),
          _section('StatTriple', const StatTriple(stats: [Stat(42, 'Students'), Stat(7, 'No team'), Stat(2, 'Need members')])),
          _section('ErrorBanner', const ErrorBanner(message: 'Needs at least 5 members (now 4)')),
          _section('ConfirmDialog', Row(children: [
            Expanded(
              child: AppButton(
                label: 'Approve dialog',
                variant: AppButtonVariant.tonal,
                onPressed: () => showConfirmDialog(context,
                    title: 'Approve team?', message: 'Tutor Match will have 6 members.', confirmLabel: 'Approve'),
              ),
            ),
            const SizedBox(width: kSpaceSm),
            Expanded(
              child: AppButton(
                label: 'Discard dialog',
                variant: AppButtonVariant.tonal,
                onPressed: () => showConfirmDialog(context,
                    title: 'Discard proposal?',
                    message: 'This cannot be undone.',
                    confirmLabel: 'Discard',
                    destructive: true),
              ),
            ),
          ])),
          _section('StatusView', SizedBox(height: 280, child: StatusView.offline(onRetry: () {}))),
          _section('LoadingView', const SizedBox(height: 80, child: LoadingView())),
        ],
      ),
    );
  }
}
