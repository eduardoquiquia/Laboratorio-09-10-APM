import 'package:flutter/material.dart';

import '../widgets/common.dart';
import 'profiles_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => const ProfilesScreen(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final opacity = t < 0.2
                ? t / 0.2
                : t > 0.8
                    ? (1 - t) / 0.2
                    : 1.0;
            return Opacity(
              opacity: opacity.clamp(0, 1).toDouble(),
              child: Transform.scale(scale: 1 + t * 0.5, child: child),
            );
          },
          child: const NetflixLogo(size: 84),
        ),
      ),
    );
  }
}
