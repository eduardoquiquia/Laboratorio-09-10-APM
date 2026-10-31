import 'package:flutter/material.dart';

import '../theme.dart';

class NetflixLogo extends StatelessWidget {
  const NetflixLogo({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(1, 1.12, 1),
      child: Text(
        'NETFLIX',
        style: displayStyle(
          size: size,
          color: NfColors.red,
          letterSpacing: size * 0.04,
        ),
      ),
    );
  }
}

class MaturityBadge extends StatelessWidget {
  const MaturityBadge(this.rating, {super.key});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: NfColors.textDim),
      ),
      child: Text(
        rating,
        style: const TextStyle(fontSize: 11, color: NfColors.textMuted),
      ),
    );
  }
}

/// Botones rectangulares "Reproducir" y "Más información".
class NfButton extends StatefulWidget {
  const NfButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = true,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final bool compact;

  @override
  State<NfButton> createState() => _NfButtonState();
}

class _NfButtonState extends State<NfButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.primary
        ? (_hover ? const Color(0xFFD6D6D6) : Colors.white)
        : Colors.grey.withValues(alpha: _hover ? 0.4 : 0.6);
    final foreground = widget.primary ? Colors.black : Colors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14 : 24,
            vertical: widget.compact ? 7 : 11,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: foreground,
                size: widget.compact ? 22 : 26,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.compact ? 14 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botones circulares: agregar a Mi lista, me gusta, más información.
class CircleAction extends StatefulWidget {
  const CircleAction({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.filled = false,
    this.size = 34,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool filled;
  final double size;

  @override
  State<CircleAction> createState() => _CircleActionState();
}

class _CircleActionState extends State<CircleAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.filled
                  ? Colors.white
                  : const Color(0xFF2A2A2A).withValues(alpha: 0.7),
              border: Border.all(
                color: widget.filled || _hover
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              widget.icon,
              size: widget.size * 0.6,
              color: widget.filled ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.color,
    this.size = 32,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.08),
      child: CustomPaint(
        size: Size.square(size),
        painter: _AvatarPainter(color),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRect(Offset.zero & size, Paint()..color = color);
    final ink = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(s * 0.33, s * 0.38), s * 0.065, ink);
    canvas.drawCircle(Offset(s * 0.67, s * 0.38), s * 0.065, ink);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.55),
        width: s * 0.56,
        height: s * 0.36,
      ),
      0.2,
      2.74,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.055
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) => oldDelegate.color != color;
}
