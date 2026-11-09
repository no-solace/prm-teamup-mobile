import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../services/config_service.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/notifications/config_demo_view_model.dart';
import '../../viewmodels/notifications/inbox_view_model.dart';
import '../../widgets/app_button.dart';

/// Lab demo: same service data and routes as the three app flows; no demo seed.
class ConfigDemoPanel extends ConsumerStatefulWidget {
  const ConfigDemoPanel({super.key});
  @override
  ConsumerState<ConfigDemoPanel> createState() => _ConfigDemoPanelState();
}

class _ConfigDemoPanelState extends ConsumerState<ConfigDemoPanel> {
  bool _refreshing = false;
  String? _classId, _error;

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      await ref.read(configDemoActionsProvider).refresh();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Refresh failed. Last values are still in use.',
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider).value ?? AppConfig.defaults;
    final enabled = ref.watch(aiMatchingEnabledProvider);
    final service = ref.watch(configDemoActionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Remote Config', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: kSpaceSm),
        Text('ai_matching_enabled: ${config.aiMatchingEnabled}'),
        Text('max_proposals_shown: ${config.maxProposalsShown}'),
        Text('Fetch: ${service.lastFetchStatus}'),
        if (service.lastFetchStatus.startsWith('fallback'))
          const Text(
            'Using saved/default settings. Check the network and retry.',
          ),
        if (_error != null) Text(_error!),
        AppButton(
          label: 'Fetch and activate',
          onPressed: _refresh,
          loading: _refreshing,
          variant: AppButtonVariant.tonal,
        ),
        const SizedBox(height: kSpaceMd),
        if (enabled)
          ref
              .watch(demoClassesProvider)
              .when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text(
                  'Class data unavailable. Load a class before testing matching.',
                ),
                data: (classes) => classes.isEmpty
                    ? const Text('Import a class to try matching.')
                    : Column(
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey(classes.map((c) => c.id).join(',')),
                            initialValue: classes.any((c) => c.id == _classId)
                                ? _classId
                                : classes.first.id,
                            decoration: const InputDecoration(
                              labelText: 'Class for matching',
                            ),
                            items: classes
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _classId = value),
                          ),
                          const SizedBox(height: kSpaceSm),
                          AppButton(
                            label: 'Match with AI',
                            icon: Icons.auto_awesome,
                            onPressed: () => context.push(
                              Routes.matching(
                                classes.any((c) => c.id == _classId)
                                    ? _classId!
                                    : classes.first.id,
                              ),
                            ),
                          ),
                        ],
                      ),
              )
        else
          const Text('AI matching is disabled by Remote Config.'),
        const SizedBox(height: kSpaceMd),
        Text(
          'Pending proposals',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        ref
            .watch(configuredProposalsProvider)
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text(
                'Proposal data unavailable. Check the network and retry.',
              ),
              data: (items) => items.isEmpty
                  ? const Text('No pending proposals.')
                  : Column(
                      children: [
                        for (final proposal in items)
                          ListTile(
                            title: Text(proposal.teamName),
                            subtitle: Text('${proposal.resultingSize} members'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.push(Routes.proposal(proposal.id)),
                          ),
                      ],
                    ),
            ),
        const SizedBox(height: kSpaceMd),
        Text(
          'FCM token (this device)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        ref
            .watch(notificationTokenProvider)
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text(
                'Token unavailable. Enable notifications and retry.',
              ),
              data: (token) => SelectableText(
                token ?? 'Enable notifications to register this device.',
              ),
            ),
      ],
    );
  }
}
