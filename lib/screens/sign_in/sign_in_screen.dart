import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/auth/sign_in_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/status_view.dart';

/// S1 Sign in + S19 (error state). Owner: Ken.
/// Deviation from Lab 2 (PROPOSAL): email field replaced by Google Sign-In.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final state = ref.watch(signInViewModelProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    if (session.isLoading && !session.hasValue) {
      return const Scaffold(body: LoadingView(label: 'Checking sign-in'));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(kSpaceLg),
              child: Column(
                children: [
                  const Spacer(),
                  Text('Sign in', style: text.headlineSmall),
                  const SizedBox(height: kSpaceSm),
                  Text('Build balanced teams', style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
                  const Spacer(),
                  if (state.error != null) ...[
                    ErrorBanner(message: state.error!.message),
                    const SizedBox(height: kSpaceMd),
                  ],
                  AppButton(
                    label: state.error == null ? 'Continue with Google' : 'Try again',
                    icon: Icons.login,
                    loading: state.loading,
                    onPressed: () => ref.read(signInViewModelProvider.notifier).signIn(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
