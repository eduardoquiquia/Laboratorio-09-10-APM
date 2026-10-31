import 'package:flutter/material.dart';

import '../models/media.dart';
import '../theme.dart';
import 'title_card.dart';

/// Carrusel horizontal con flechas al pasar el mouse.
class _Carousel extends StatefulWidget {
  const _Carousel({
    required this.title,
    required this.height,
    required this.itemWidth,
    required this.itemCount,
    required this.itemBuilder,
    this.gap = 8,
  });

  final String title;
  final double height;
  final double itemWidth;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double gap;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final _controller = ScrollController();
  bool _hover = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _page(int direction) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final target = (position.pixels + direction * position.viewportDimension * 0.9)
        .clamp(0.0, position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final isDesktop = width >= kDesktopBreakpoint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 0, pad, 10),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: isDesktop ? 20 : 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE5E5E5),
              ),
            ),
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: SizedBox(
              height: widget.height,
              child: Stack(
                children: [
                  ListView.separated(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    itemCount: widget.itemCount,
                    separatorBuilder: (_, _) => SizedBox(width: widget.gap),
                    itemBuilder: (context, index) => SizedBox(
                      width: widget.itemWidth,
                      child: widget.itemBuilder(context, index),
                    ),
                  ),
                  if (isDesktop && _hover) ...[
                    _Arrow(
                      left: true,
                      width: pad,
                      onTap: () => _page(-1),
                    ),
                    _Arrow(
                      left: false,
                      width: pad,
                      onTap: () => _page(1),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.left,
    required this.width,
    required this.onTap,
  });

  final bool left;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: 0,
      bottom: 0,
      width: width,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Icon(
              left ? Icons.chevron_left : Icons.chevron_right,
              size: 38,
            ),
          ),
        ),
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  const TitleRow({
    super.key,
    required this.title,
    required this.items,
    this.progressOf,
  });

  final String title;
  final List<Media> items;
  final double Function(Media)? progressOf;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    const gap = 8.0;
    final columns = width >= 1400
        ? 6
        : width >= 1000
            ? 5
            : width >= kDesktopBreakpoint
                ? 4
                : 2;
    final available = width - pad * 2 - gap * (columns - 1);
    final itemWidth =
        width < kDesktopBreakpoint ? 180.0 : available / columns;
    final extra = progressOf == null ? 0.0 : 8.0;
    return _Carousel(
      title: title,
      height: itemWidth * 9 / 16 + extra,
      itemWidth: itemWidth,
      gap: gap,
      itemCount: items.length,
      itemBuilder: (context, index) => TitleCard(
        media: items[index],
        progress: progressOf?.call(items[index]),
      ),
    );
  }
}

/// Fila "Top 10" con el número gigante detrás de cada portada vertical.
class Top10Row extends StatelessWidget {
  const Top10Row({super.key, required this.title, required this.items});

  final String title;
  final List<Media> items;

  /// Con menos títulos, un ranking de "las 10 más populares" no tiene sentido.
  static const _minItems = 3;

  @override
  Widget build(BuildContext context) {
    if (items.length < _minItems) return const SizedBox.shrink();
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final height = isDesktop ? 210.0 : 160.0;
    final posterWidth = height * 2 / 3;
    return _Carousel(
      title: title,
      height: height,
      itemWidth: posterWidth * 1.75,
      gap: 12,
      itemCount: items.length,
      itemBuilder: (context, index) => Stack(
        children: [
          Positioned(
            left: 0,
            bottom: -height * 0.08,
            child: Text(
              '${index + 1}',
              style: displayStyle(
                size: height * 1.2,
                letterSpacing: -6,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = const Color(0xFF7A7A7A),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: posterWidth,
            child: TitleCard(media: items[index], aspectRatio: 2 / 3),
          ),
        ],
      ),
    );
  }
}
