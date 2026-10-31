import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NfColors {
  static const background = Color(0xFF141414);
  static const surface = Color(0xFF181818);
  static const surfaceHigh = Color(0xFF2F2F2F);
  static const red = Color(0xFFE50914);
  static const redDark = Color(0xFFB20710);
  static const match = Color(0xFF46D369);
  static const textMuted = Color(0xFFB3B3B3);
  static const textDim = Color(0xFF808080);
}

/// Ancho a partir del cual se usa la navegación superior de escritorio.
const double kDesktopBreakpoint = 800;

double pagePadding(double width) => width < kDesktopBreakpoint ? 16 : 48;

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: NfColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: NfColors.red,
      secondary: NfColors.red,
      surface: NfColors.surface,
    ),
    textTheme: base.textTheme.apply(fontFamily: GoogleFonts.inter().fontFamily),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
}

/// Tipografía condensada para logo y títulos de las producciones.
TextStyle displayStyle({
  required double size,
  Color color = Colors.white,
  Paint? foreground,
  List<Shadow>? shadows,
  double letterSpacing = 1,
}) {
  return GoogleFonts.bebasNeue(
    fontSize: size,
    color: foreground == null ? color : null,
    foreground: foreground,
    shadows: shadows,
    letterSpacing: letterSpacing,
    height: 1,
  );
}
