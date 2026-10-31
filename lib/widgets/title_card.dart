import 'dart:async';

import 'package:flutter/material.dart';

import '../models/media.dart';
import '../screens/detail_modal.dart';
import '../screens/player_screen.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';
import 'poster_art.dart';

/// Tarjeta de catálogo. Con el mouse encima abre la vista previa ampliada.
class TitleCard extends StatefulWidget {
  const TitleCard({
    super.key,
    required this.media,
    this.progress,
    this.aspectRatio = 16 / 9,
  });

  final Media media;
  final double? progress;
  final double aspectRatio;

  @override
  State<TitleCard> createState() => _TitleCardState();
}

class _TitleCardState extends State<TitleCard> {
  static const _hoverDelay = Duration(milliseconds: 380);

  Timer? _timer;
  OverlayEntry? _entry;

  void _closePreview() {
    _entry?.remove();
    _entry = null;
  }

  void _openPreview() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || _entry != null) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final entry = OverlayEntry(
      builder: (_) => _HoverPreview(
        media: widget.media,
        anchor: rect,
        onClose: _closePreview,
      ),
    );
    _entry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _closePreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _timer?.cancel();
        _timer = Timer(_hoverDelay, _openPreview);
      },
      onExit: (_) => _timer?.cancel(),
      child: GestureDetector(
        onTap: () {
          _timer?.cancel();
          showDetail(context, widget.media);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: PosterArt(media: widget.media),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 5),
              ProgressLine(value: progress),
            ],
          ],
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: const Color(0xFF5A5A5A),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1).toDouble(),
        child: Container(color: NfColors.red),
      ),
    );
  }
}

class _HoverPreview extends StatelessWidget {
  const _HoverPreview({
    required this.media,
    required this.anchor,
    required this.onClose,
  });

  final Media media;
  final Rect anchor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final screen = MediaQuery.sizeOf(context);
    final width = (anchor.width * 1.45).clamp(280.0, 400.0);
    final artHeight = width * 9 / 16;
    const infoHeight = 134.0;
    final left = (anchor.center.dx - width / 2)
        .clamp(8.0, screen.width - width - 8)
        .toDouble();
    final top = (anchor.center.dy - artHeight / 2)
        .clamp(8.0, screen.height - artHeight - infoHeight - 8)
        .toDouble();
    final inList = state.inMyList(media);
    final liked = state.isLiked(media);

    return Positioned(
      left: left,
      top: top,
      width: width,
      child: Listener(
        // La rueda del mouse mueve la página, así que la vista previa se cierra.
        onPointerSignal: (_) => onClose(),
        child: MouseRegion(
          onExit: (_) => onClose(),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.75, end: 1),
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Material(
              color: NfColors.surface,
              elevation: 12,
              borderRadius: BorderRadius.circular(6),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      onClose();
                      showDetail(context, media);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        height: artHeight,
                        width: double.infinity,
                        child: PosterArt(media: media),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (!media.comingSoon) ...[
                              CircleAction(
                                icon: Icons.play_arrow,
                                tooltip: 'Reproducir',
                                filled: true,
                                onTap: () {
                                  onClose();
                                  openPlayer(context, media);
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                            CircleAction(
                              icon: inList ? Icons.check : Icons.add,
                              tooltip: inList
                                  ? 'Quitar de Mi lista'
                                  : 'Agregar a Mi lista',
                              onTap: () => state.toggleMyList(media),
                            ),
                            const SizedBox(width: 8),
                            CircleAction(
                              icon: liked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              tooltip: 'Me gusta',
                              onTap: () => state.toggleLiked(media),
                            ),
                            const Spacer(),
                            CircleAction(
                              icon: Icons.keyboard_arrow_down,
                              tooltip: 'Más información',
                              onTap: () {
                                onClose();
                                showDetail(context, media);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${media.match}% para ti',
                              style: const TextStyle(
                                color: NfColors.match,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MaturityBadge(media.rating),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                media.durationLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          media.genres.join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
