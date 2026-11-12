import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/onboarding_view_model.dart';
import '../../viewmodels/profile/profile_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_banner.dart';

/// First sign-in: pick a role. Students link to the class list their mentor
/// imported (class code + MSSV); the role cannot be changed afterwards.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _classId = TextEditingController();
  final _studentId = TextEditingController();
  bool _student = true;
  bool _leader = false;

  @override
  void dispose() {
    _classId.dispose();
    _studentId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final vm = ref.read(onboardingProvider.notifier);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView(
            padding: kScreenPadding,
            children: [
              Text('Who are you?', style: text.titleLarge),
              const SizedBox(height: kSpaceMd),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(Icons.groups_outlined), label: Text('Student')),
                  ButtonSegment(value: false, icon: Icon(Icons.school_outlined), label: Text('Mentor')),
                ],
                selected: {_student},
                onSelectionChanged: (s) => setState(() => _student = s.first),
              ),
              const SizedBox(height: kSpaceLg),
              if (_student) ...[
                Text(
                  'Ask your mentor for the class code. Your team must already be approved.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: kSpaceMd),
                TextField(
                  controller: _classId,
                  decoration: const InputDecoration(labelText: 'Class code', border: OutlineInputBorder()),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: kSpaceMd),
                TextField(
                  controller: _studentId,
                  decoration: const InputDecoration(labelText: 'Student ID (MSSV)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: kSpaceSm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I am the team leader'),
                  subtitle: const Text('Leaders submit the topic and book meetings'),
                  value: _leader,
                  onChanged: (v) => setState(() => _leader = v),
                ),
              ] else
                Text(
                  'Mentors import class lists, match teams, review topics and run meetings.',
                  style: text.bodyMedium,
                ),
              const SizedBox(height: kSpaceLg),
              if (state.error != null) ErrorBanner(message: state.error!.message),
              AppButton(
                label: 'Continue',
                loading: state.busy,
                onPressed: () => _student
                    ? vm.joinTeam(classId: _classId.text, studentId: _studentId.text, leader: _leader)
                    : vm.becomeMentor(),
              ),
              const SizedBox(height: kSpaceSm),
              AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.text,
                onPressed: ref.read(profileViewModelProvider.notifier).signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
