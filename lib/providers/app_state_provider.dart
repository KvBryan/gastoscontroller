import 'package:flutter/material.dart';
import 'app_state.dart';

class AppStateProvider extends InheritedWidget {
  final AppState state;

  const AppStateProvider({
    super.key,
    required this.state,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final AppStateProvider? result = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(result != null, 'No AppStateProvider found in context');
    return result!.state;
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) {
    return state != oldWidget.state;
  }
}
