import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// Exposes the shared [AppState] to the widget tree.
///
/// Uses the built-in [InheritedNotifier], so widgets that call [of] rebuild
/// whenever the state notifies its listeners.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  /// Returns the state and subscribes the caller to changes.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado no contexto.');
    return scope!.notifier!;
  }

  /// Returns the state without subscribing the caller to changes.
  ///
  /// Use inside callbacks (button handlers, navigation) instead of [of].
  static AppState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppScope>();
    final scope = element?.widget;
    assert(scope is AppScope, 'AppScope não encontrado no contexto.');
    return (scope! as AppScope).notifier!;
  }
}
