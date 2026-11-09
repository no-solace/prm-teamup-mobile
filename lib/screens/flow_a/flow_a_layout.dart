import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';

/// Flow A's pushed pages sit above the tab shell. Keep scrollable content and
/// the sticky action independently constrained on wide displays.
class FlowAScaffold extends StatelessWidget {
  const FlowAScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.onBack,
  });
  final String title;
  final Widget body;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      leading: BackButton(onPressed: onBack ?? () => leaveFlowAPage(context)),
    ),
    body: SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: body,
        ),
      ),
    ),
    bottomNavigationBar: bottom == null
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: kScreenPadding,
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                  child: bottom,
                ),
              ),
            ),
          ),
  );
}

void leaveFlowAPage(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.classes);
  }
}

class FlowANote extends StatelessWidget {
  const FlowANote({super.key, required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: kSpaceSm),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpaceXs),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class FlowAInfoRow extends StatelessWidget {
  const FlowAInfoRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: kSpaceSm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

class ClassDestinationRow extends StatelessWidget {
  const ClassDestinationRow({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label, $count',
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text('$count'), const Icon(Icons.chevron_right)],
      ),
      onTap: onTap,
    ),
  );
}
