import '../services/app_error.dart';

/// Explicit state model for every data-loading screen (C4, D4).
/// `switch` over it is exhaustive, so a screen cannot forget a state.
sealed class ViewState<T> {
  const ViewState();
}

class Loading<T> extends ViewState<T> {
  const Loading();
}

class Empty<T> extends ViewState<T> {
  const Empty();
}

class Data<T> extends ViewState<T> {
  const Data(this.value);
  final T value;
}

class Failure<T> extends ViewState<T> {
  const Failure(this.error);
  final AppError error;
}

/// Turns any thrown object into an [AppError] (services should already do this).
AppError toAppError(Object e) => e is AppError ? e : UnknownError('Something went wrong', e);
