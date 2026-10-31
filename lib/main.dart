import 'dart:ui';

import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() {
  runApp(const NetflixCloneApp());
}

class NetflixCloneApp extends StatefulWidget {
  const NetflixCloneApp({super.key});

  @override
  State<NetflixCloneApp> createState() => _NetflixCloneAppState();
}

class _NetflixCloneAppState extends State<NetflixCloneApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: _state,
      child: MaterialApp(
        title: 'Netflix',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        scrollBehavior: const _DragScrollBehavior(),
        home: const SplashScreen(),
      ),
    );
  }
}

/// Permite arrastrar las filas con el mouse, además del touch.
class _DragScrollBehavior extends MaterialScrollBehavior {
  const _DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
