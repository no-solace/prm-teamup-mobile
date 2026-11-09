import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/proposal.dart';
import '../../router/routes.dart';
import '../../services/app_error.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/matching_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_view.dart';
import 'flow_a_layout.dart';

/// S8 and S18 are states of one page. Retry restarts the bounded operation;
/// leaving the page ignores late service results and prevents navigation.
class MatchingScreen extends ConsumerWidget {
  const MatchingScreen({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = matchingViewModelProvider(classId);
    final state = ref.watch(provider);
    final model = ref.read(provider.notifier);
    ref.listen(provider, (_, next) {
      if (!context.mounted) return;
      switch (next) {
        case Data<List<Proposal>>():
          context.go(Routes.proposals);
        case Empty<List<Proposal>>():
          context.replace(Routes.noMatch(classId));
        default:
          break;
      }
    });
    void cancel() {
      model.cancel();
      leaveFlowAPage(context);
    }

    final failed = state is Failure<List<Proposal>>;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) model.cancel();
      },
      child: FlowAScaffold(
        title: failed ? 'Offline' : 'AI matching',
        onBack: cancel,
        body: switch (state) {
          Failure(:final error) =>
            error is NetworkError || error is TimeoutAppError
                ? StatusView(
                    icon: Icons.wifi_off,
                    title: "You're offline",
                    message: error is TimeoutAppError
                        ? error.message
                        : 'Check your connection and try again.',
                    actionLabel: 'Try again',
                    onAction: model.start,
                  )
                : StatusView.error(
                    message: error.message,
                    onRetry: model.start,
                  ),
          _ => Center(
            child: SingleChildScrollView(
              padding: kScreenPadding,
              child: Semantics(
                liveRegion: true,
                label: 'AI matching in progress. Balancing majors and teams of 5 to 6 members.',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: kSpaceLg),
                    Text(
                      'Finding the best teams…',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpaceSm),
                    const Text(
                      'Balancing majors and teams of 5–6 members.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        },
        bottom: AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: cancel,
        ),
      ),
    );
  }
}
