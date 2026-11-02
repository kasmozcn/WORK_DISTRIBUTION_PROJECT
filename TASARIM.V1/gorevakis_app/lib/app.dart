import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/repository.dart';
import 'screens/login_screen.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class GorevAkisApp extends StatefulWidget {
  const GorevAkisApp({super.key, required this.repository});

  /// Verinin nereden geldiği. Şu an FakeRepository; veritabanı hazır
  /// olunca gerçek repository verilir.
  final GorevRepository repository;

  @override
  State<GorevAkisApp> createState() => _GorevAkisAppState();
}

class _GorevAkisAppState extends State<GorevAkisApp> {
  late final AppState _state = AppState(widget.repository);

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'GörevAkış',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('tr', 'TR'),
        supportedLocales: const [Locale('tr', 'TR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LoginScreen(),
      ),
    );
  }
}
