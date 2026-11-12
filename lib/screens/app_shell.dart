import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';

/// Bottom navigation (C8). Each tab keeps its own stack.
///
/// Branch order: 0 Classes, 1 Proposals (mentor only), 2 Topics, 3 Schedule,
/// 4 Profile. A student sees "My team" instead of "Classes" and has no
/// Proposals tab.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _all = [
    (branch: 0, icon: Icons.school_outlined, selected: Icons.school, label: 'Classes'),
    (branch: 1, icon: Icons.auto_awesome_outlined, selected: Icons.auto_awesome, label: 'Proposals'),
    (branch: 2, icon: Icons.lightbulb_outline, selected: Icons.lightbulb, label: 'Topics'),
    (branch: 3, icon: Icons.event_outlined, selected: Icons.event, label: 'Schedule'),
    (branch: 4, icon: Icons.person_outline, selected: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(sessionProvider).value?.isStudent ?? false;
    final pending = ref.watch(pendingProposalsProvider).value?.length ?? 0;
    final tabs = [
      for (final t in _all)
        if (!(student && t.branch == 1))
          student && t.branch == 0
              ? (branch: 0, icon: Icons.groups_outlined, selected: Icons.groups, label: 'My team')
              : t,
    ];
    final index = tabs.indexWhere((t) => t.branch == shell.currentIndex);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        // Tapping the current tab again pops back to its root.
        onDestinationSelected: (i) {
          final branch = tabs[i].branch;
          shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
        },
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              // The Proposals tab carries the pending-proposal badge of Lab 2 S9.
              icon: t.branch == 1 ? _badge(pending, t.icon) : Icon(t.icon),
              selectedIcon: t.branch == 1 ? _badge(pending, t.selected) : Icon(t.selected),
              label: t.label,
            ),
        ],
      ),
    );
  }

  /// Wraps the Proposals icon in the pending-proposal badge.
  Widget _badge(int pending, IconData icon) => Badge(
        isLabelVisible: pending > 0,
        label: Text('$pending'),
        child: Icon(icon),
      );
}

/// The badge used on the Proposals tab and in the S9 app bar.
class ProposalsBadge extends StatelessWidget {
  const ProposalsBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$count pending proposals',
      child: Container(
        constraints: const BoxConstraints(minWidth: kTouchTarget),
        height: kTouchTarget,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: kSpaceSm),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: radius(kRadiusFull),
        ),
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
