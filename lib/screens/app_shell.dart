import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';

/// Bottom navigation with 3 tabs (C8). Each tab keeps its own stack.
/// The Proposals tab carries the pending-proposal badge of Lab 2 S9.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingProposalsProvider).value?.length ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tapping the current tab again pops back to its root.
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.auto_awesome_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.auto_awesome),
            ),
            label: 'Proposals',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
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
