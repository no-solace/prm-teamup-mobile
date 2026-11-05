import 'package:flutter/material.dart';

import '../services/app_error.dart';
import '../viewmodels/view_state.dart';
import 'status_view.dart';

/// Renders a [ViewState] (D4). Defaults give every screen the same loading,
/// empty and error UI; pass builders to follow a specific Figma state.
class ViewStateBuilder<T> extends StatelessWidget {
  const ViewStateBuilder({
    super.key,
    required this.state,
    required this.data,
    this.loading,
    this.empty,
    this.error,
    this.onRetry,
  });

  final ViewState<T> state;
  final Widget Function(BuildContext context, T value) data;
  final WidgetBuilder? loading;
  final WidgetBuilder? empty;
  final Widget Function(BuildContext context, AppError error)? error;

  /// "Try again" on the default error state.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
        Loading() => loading?.call(context) ?? const LoadingView(),
        Empty() => empty?.call(context) ?? const StatusView(icon: Icons.inbox_outlined, title: 'Nothing here yet'),
        Data(:final value) => data(context, value),
        Failure(error: final e) => error?.call(context, e) ??
            (e is NetworkError
                ? StatusView.offline(onRetry: onRetry)
                : StatusView.error(message: e.message, onRetry: onRetry)),
      };
}
