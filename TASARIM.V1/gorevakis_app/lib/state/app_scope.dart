import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// [AppState]'i ağaçtaki tüm ekranlara ulaştırır.
///
/// `AppScope.of(context)` build içinde kullanılır; durum değişince ekran
/// yeniden çizilir. Buton gibi olaylarda ve initState içinde
/// `AppScope.read(context)` kullanılır.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope bulunamadı');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppScope>();
    assert(element != null, 'AppScope bulunamadı');
    return (element!.widget as AppScope).notifier!;
  }
}
