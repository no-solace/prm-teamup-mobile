import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/auth/sign_in_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/status_view.dart';

/// S1 / S19. Controllers own temporary input only; validation lives in the VM.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _showPassword = false;
  bool _phoneConsent = false;

  @override
  void dispose() {
    for (final controller in [
      _email,
      _password,
      _confirmation,
      _phone,
      _code,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectMethod(SignInMethod method) {
    _password.clear();
    _confirmation.clear();
    _code.clear();
    ref.read(signInViewModelProvider.notifier).selectMethod(method);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final state = ref.watch(signInViewModelProvider);
    final vm = ref.read(signInViewModelProvider.notifier);
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
            child: AutofillGroup(
              child: ListView(
                padding: const EdgeInsets.all(kSpaceLg),
                children: [
                  const SizedBox(height: kSpaceXl),
                  Text(
                    state.registering ? 'Create account' : 'Sign in',
                    style: text.headlineSmall,
                  ),
                  const SizedBox(height: kSpaceSm),
                  Text(
                    'Build balanced teams',
                    style: text.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: kSpaceLg),
                  if (session.hasError) ...[
                    const ErrorBanner(
                      message:
                          'Unable to check your session. Please try again.',
                    ),
                    AppButton(
                      label: 'Retry session',
                      variant: AppButtonVariant.text,
                      onPressed: () => ref.invalidate(sessionProvider),
                    ),
                  ],
                  for (final method in SignInMethod.values) ...[
                    AppButton(
                      label: switch (method) {
                        SignInMethod.google => 'Continue with Google',
                        SignInMethod.email => 'Email and password',
                        SignInMethod.phone => 'Phone number',
                      },
                      variant: state.method == method
                          ? AppButtonVariant.primary
                          : AppButtonVariant.tonal,
                      icon: switch (method) {
                        SignInMethod.google => Icons.login,
                        SignInMethod.email => Icons.mail_outline,
                        SignInMethod.phone => Icons.phone_outlined,
                      },
                      loading:
                          method == SignInMethod.google &&
                          state.method == method &&
                          state.loading,
                      onPressed: state.loading
                          ? null
                          : () {
                              if (method == SignInMethod.google) {
                                _selectMethod(method);
                                vm.signIn();
                              } else {
                                _selectMethod(method);
                              }
                            },
                    ),
                    const SizedBox(height: kSpaceSm),
                  ],
                  const SizedBox(height: kSpaceMd),
                  if (state.error != null) ...[
                    ErrorBanner(message: state.error!.message),
                    const SizedBox(height: kSpaceMd),
                  ],
                  if (state.info != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(state.info!, style: text.bodyMedium),
                    ),
                    const SizedBox(height: kSpaceMd),
                  ],
                  if (state.method == SignInMethod.email) ...[
                    AppTextField(
                      controller: _email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !state.loading,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: kSpaceMd),
                    AppTextField(
                      controller: _password,
                      label: 'Password',
                      obscureText: !_showPassword,
                      enabled: !state.loading,
                      autofillHints: [
                        state.registering
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      suffix: IconButton(
                        tooltip: _showPassword
                            ? 'Hide password'
                            : 'Show password',
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    if (state.registering) ...[
                      const SizedBox(height: kSpaceMd),
                      AppTextField(
                        controller: _confirmation,
                        label: 'Confirm password',
                        obscureText: true,
                        enabled: !state.loading,
                      ),
                    ],
                    const SizedBox(height: kSpaceMd),
                    AppButton(
                      label: state.registering
                          ? 'Create account'
                          : 'Sign in with email',
                      loading: state.loading,
                      onPressed: () => vm.submitEmail(
                        _email.text,
                        _password.text,
                        confirmation: _confirmation.text,
                      ),
                    ),
                    const SizedBox(height: kSpaceSm),
                    AppButton(
                      label: state.registering
                          ? 'Already have an account? Sign in'
                          : 'Create an email account',
                      variant: AppButtonVariant.text,
                      onPressed: state.loading
                          ? null
                          : () {
                              _password.clear();
                              _confirmation.clear();
                              vm.toggleRegistration();
                            },
                    ),
                  ],
                  if (state.method == SignInMethod.phone) ...[
                    AppTextField(
                      controller: _phone,
                      label: 'Phone number with country code',
                      hint: '+84912345678',
                      keyboardType: TextInputType.phone,
                      enabled: !state.loading && !state.codeSent,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    const SizedBox(height: kSpaceSm),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _phoneConsent,
                      onChanged: state.loading || state.codeSent
                          ? null
                          : (value) =>
                                setState(() => _phoneConsent = value ?? false),
                      title: const Text(
                        'I agree to SMS verification. SMS charges may apply.',
                      ),
                      subtitle: const Text(
                        'Google will receive and store this number to prevent spam and abuse.',
                      ),
                    ),
                    if (!state.codeSent)
                      AppButton(
                        label: 'Send SMS code',
                        loading: state.loading,
                        onPressed: _phoneConsent
                            ? () => vm.requestPhoneCode(
                                _phone.text,
                                consent: _phoneConsent,
                              )
                            : null,
                      ),
                    if (state.codeSent) ...[
                      const SizedBox(height: kSpaceMd),
                      AppTextField(
                        controller: _code,
                        label: '6-digit SMS code',
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        enabled: !state.loading,
                        autofillHints: const [AutofillHints.oneTimeCode],
                      ),
                      const SizedBox(height: kSpaceMd),
                      AppButton(
                        label: 'Verify and sign in',
                        loading: state.loading,
                        onPressed: () => vm.confirmPhoneCode(_code.text),
                      ),
                      const SizedBox(height: kSpaceSm),
                      AppButton(
                        label: state.resendSeconds > 0
                            ? 'Resend code in ${state.resendSeconds}s'
                            : 'Resend SMS code',
                        variant: AppButtonVariant.text,
                        onPressed: state.loading || state.resendSeconds > 0
                            ? null
                            : () {
                                _code.clear();
                                vm.requestPhoneCode(
                                  _phone.text,
                                  resend: true,
                                  consent: _phoneConsent,
                                );
                              },
                      ),
                    ],
                    const SizedBox(height: kSpaceSm),
                    AppButton(
                      label: 'Cancel phone sign-in',
                      variant: AppButtonVariant.text,
                      onPressed: state.loading && state.codeSent
                          ? null
                          : () {
                              _code.clear();
                              vm.cancelPhone();
                            },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
