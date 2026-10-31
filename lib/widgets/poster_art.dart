import 'dart:math';

import 'package:flutter/material.dart';

import '../models/media.dart';
import '../theme.dart';

/// Portada generada por código a partir de la paleta de cada título.
class PosterArt extends StatelessWidget {
  const PosterArt({super.key, required this.media, this.showTitle = true});

  final Media media;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(painter: _PosterPainter(media)),
            ),
            if (showTitle)
              Positioned(
                left: w * 0.06,
                right: w * 0.06,
                bottom: w * 0.05,
                child: Text(
                  media.title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: displayStyle(
                    size: (w * 0.115).clamp(13, 64).toDouble(),
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black),
                    ],
                  ),
                ),
              ),
            if (showTitle && media.isOriginal)
              Positioned(
                left: w * 0.03,
                top: w * 0.02,
                child: Text(
                  'N',
                  style: displayStyle(
                    size: (w * 0.1).clamp(12, 34).toDouble(),
                    color: NfColors.red,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PosterPainter extends CustomPainter {
  const _PosterPainter(this.media);

  final Media media;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final random = Random(media.seed);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(random.nextDouble() * 2 - 1, -1),
          end: Alignment(random.nextDouble() * 2 - 1, 1),
          colors: [media.primary, media.secondary],
        ).createShader(rect),
    );

    switch (media.seed % 6) {
      case 0:
        _paintSun(canvas, size, random);
      case 1:
        _paintMountains(canvas, size, random);
      case 2:
        _paintCity(canvas, size, random);
      case 3:
        _paintBeams(canvas, size, random);
      case 4:
        _paintRings(canvas, size, random);
      default:
        _paintWaves(canvas, size);
    }

    // Viñeta inferior para que el título siempre sea legible.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.45, 1],
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
        ).createShader(rect),
    );
  }

  void _paintFigure(Canvas canvas, Offset feet, double height) {
    final paint = Paint()..color = media.secondary;
    final head = height * 0.13;
    canvas.drawCircle(feet.translate(0, -height + head), head, paint);
    final body = Path()
      ..moveTo(feet.dx - height * 0.08, feet.dy - height * 0.72)
      ..lineTo(feet.dx + height * 0.08, feet.dy - height * 0.72)
      ..lineTo(feet.dx + height * 0.17, feet.dy)
      ..lineTo(feet.dx - height * 0.17, feet.dy)
      ..close();
    canvas.drawPath(body, paint);
  }

  void _paintSun(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * (0.55 + random.nextDouble() * 0.25), h * 0.42);
    final radius = min(w, h) * 0.3;
    final glow = Rect.fromCircle(center: center, radius: radius * 2.6);
    canvas.drawCircle(
      center,
      radius * 2.6,
      Paint()
        ..shader = RadialGradient(
          colors: [
            media.accent.withValues(alpha: 0.65),
            media.accent.withValues(alpha: 0),
          ],
        ).createShader(glow),
    );
    canvas.drawCircle(center, radius, Paint()..color = media.accent);
    final horizon = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.35, h * 0.6, w * 0.65, h * 0.72)
      ..quadraticBezierTo(w * 0.85, h * 0.8, w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(horizon, Paint()..color = media.secondary);
    _paintFigure(canvas, Offset(w * 0.3, h * 0.68), h * 0.3);
  }

  void _paintMountains(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(
      Offset(w * 0.75, h * 0.25),
      min(w, h) * 0.1,
      Paint()..color = media.accent.withValues(alpha: 0.9),
    );
    for (var layer = 0; layer < 3; layer++) {
      final base = h * (0.55 + layer * 0.14);
      final path = Path()..moveTo(0, h);
      var x = 0.0;
      path.lineTo(0, base);
      while (x < w) {
        final step = w * (0.1 + random.nextDouble() * 0.14);
        path.lineTo(x + step / 2, base - h * (0.08 + random.nextDouble() * 0.2));
        path.lineTo(x + step, base);
        x += step;
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(media.primary, media.secondary, layer / 2)!,
      );
    }
  }

  void _paintCity(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final building = Paint()..color = media.secondary;
    final window = Paint()..color = media.accent.withValues(alpha: 0.85);
    var x = 0.0;
    while (x < w) {
      final bw = w * (0.07 + random.nextDouble() * 0.07);
      final bh = h * (0.3 + random.nextDouble() * 0.5);
      final top = h - bh;
      canvas.drawRect(Rect.fromLTWH(x, top, bw, bh), building);
      final unit = bw / 5;
      for (var wy = top + unit; wy < h - unit; wy += unit * 2) {
        for (var wx = x + unit; wx < x + bw - unit; wx += unit * 2) {
          if (random.nextDouble() > 0.55) {
            canvas.drawRect(Rect.fromLTWH(wx, wy, unit, unit), window);
          }
        }
      }
      x += bw + w * 0.008;
    }
  }

  void _paintBeams(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final origin = Offset(w * 0.5, -h * 0.1);
    for (var i = 0; i < 5; i++) {
      final spread = (i - 2) * w * 0.26 + random.nextDouble() * w * 0.06;
      final beam = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(w * 0.5 + spread - w * 0.09, h)
        ..lineTo(w * 0.5 + spread + w * 0.09, h)
        ..close();
      canvas.drawPath(
        beam,
        Paint()..color = media.accent.withValues(alpha: 0.16),
      );
    }
    _paintFigure(canvas, Offset(w * 0.5, h * 0.95), h * 0.55);
  }

  void _paintRings(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * (0.3 + random.nextDouble() * 0.4), h * 0.45);
    for (var i = 1; i <= 6; i++) {
      canvas.drawCircle(
        center,
        min(w, h) * 0.09 * i,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = min(w, h) * 0.012
          ..color = media.accent.withValues(alpha: 0.75 - i * 0.1),
      );
    }
    canvas.drawCircle(
      center,
      min(w, h) * 0.05,
      Paint()..color = media.accent,
    );
  }

  void _paintWaves(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (var layer = 0; layer < 4; layer++) {
      final base = h * (0.5 + layer * 0.12);
      final path = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w; x += w / 40) {
        path.lineTo(
          x,
          base + sin(x / w * pi * (3 + layer) + layer) * h * 0.05,
        );
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(media.accent, media.secondary, 0.35 + layer * 0.2)!
              .withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_PosterPainter oldDelegate) =>
      oldDelegate.media.id != media.id;
}
