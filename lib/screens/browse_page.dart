import 'dart:math';

import 'package:flutter/material.dart';

import '../models/media.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/poster_art.dart';
import '../widgets/title_row.dart';
import 'collection_pages.dart';
import 'detail_modal.dart';
import 'player_screen.dart';

/// Inicio, Series y Películas: billboard más filas de categorías.
class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key, this.type});

  /// Con null se muestra todo el catálogo (Inicio).
  final MediaType? type;

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  String? _genre;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final type = widget.type;
    final items = state.ofType(type);
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);

    if (items.isEmpty) {
      return const Center(child: Text('No hay títulos para este perfil.'));
    }

    final selected = _genre;
    if (selected != null) {
      return TitleGrid(
        items: state.byGenre(selected, type),
        header: _GenreHeader(
          type: type,
          value: selected,
          onChanged: (value) => setState(() => _genre = value),
        ),
      );
    }

    final top = state.top10(type);
    final featured = top.isNotEmpty ? top.first : items.first;
    final name = state.current?.name ?? '';
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            _Billboard(media: featured, inTop10: top.isNotEmpty),
            if (type != null)
              Positioned(
                left: pad,
                top: width >= kDesktopBreakpoint ? 72 : 96,
                child: _GenreHeader(
                  type: type,
                  value: null,
                  onChanged: (value) => setState(() => _genre = value),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (type == null)
          TitleRow(
            title: 'Continuar viendo para $name',
            items: state.continueWatching,
            progressOf: state.progressOf,
          ),
        Top10Row(
          title: switch (type) {
            MediaType.series => 'Las 10 series más populares hoy',
            MediaType.movie => 'Las 10 películas más populares hoy',
            null => 'Las 10 más populares hoy',
          },
          items: top,
        ),
        TitleRow(title: 'Mi lista', items: state.myList),
        TitleRow(
          title: 'Solo en Netflix',
          items: items.where((m) => m.isOriginal).toList(),
        ),
        TitleRow(
          title: 'Agregados recientemente',
          items: items.where((m) => m.isNew).toList(),
        ),
        for (final genre in state.genres(type))
          if (state.byGenre(genre, type).length >= 3)
            TitleRow(title: genre, items: state.byGenre(genre, type)),
        const _Footer(),
      ],
    );
  }
}

class _GenreHeader extends StatelessWidget {
  const _GenreHeader({
    required this.type,
    required this.value,
    required this.onChanged,
  });

  final MediaType? type;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDesktop) ...[
          Text(
            type == MediaType.movie ? 'Películas' : 'Series',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 24),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white),
          ),
          child: DropdownButton<String?>(
            value: value,
            isDense: true,
            underline: const SizedBox.shrink(),
            dropdownColor: Colors.black,
            hint: const Text('Géneros', style: TextStyle(fontSize: 14)),
            style: const TextStyle(fontSize: 14, color: Colors.white),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todos los géneros'),
              ),
              for (final genre in state.genres(type))
                DropdownMenuItem<String?>(value: genre, child: Text(genre)),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _Billboard extends StatefulWidget {
  const _Billboard({required this.media, required this.inTop10});

  final Media media;
  final bool inTop10;

  @override
  State<_Billboard> createState() => _BillboardState();
}

class _BillboardState extends State<_Billboard>
    with SingleTickerProviderStateMixin {
  // Acercamiento lento de la imagen, a falta de un tráiler en video.
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= kDesktopBreakpoint;
    final pad = pagePadding(size.width);
    // La altura mínima evita que el texto se monte sobre la barra superior
    // en ventanas bajas.
    final height = max(
      isDesktop
          ? min(size.width * 9 / 16, size.height * 0.92)
          : size.height * 0.72,
      isDesktop ? 560.0 : 520.0,
    );
    final media = widget.media;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.1).animate(_zoom),
              child: PosterArt(media: media, showTitle: false),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0, 0.65],
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1],
                colors: [Colors.transparent, NfColors.background],
              ),
            ),
          ),
          Positioned(
            left: pad,
            right: pad,
            bottom: isDesktop ? height * 0.16 : 28,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (media.isOriginal)
                    Row(
                      children: [
                        Text(
                          'N',
                          style: displayStyle(size: 28, color: NfColors.red),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          media.isSeries ? 'S E R I E' : 'P E L Í C U L A',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    media.title,
                    style: displayStyle(
                      size: isDesktop
                          ? (size.width * 0.065).clamp(52, 104).toDouble()
                          : 46,
                      shadows: const [
                        Shadow(blurRadius: 16, color: Colors.black87),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.inTop10)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NfColors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'TOP\n10',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nº 1 en el Top 10 de hoy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Text(
                    media.synopsis,
                    maxLines: isDesktop ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 13,
                      height: 1.35,
                      shadows: const [
                        Shadow(blurRadius: 6, color: Colors.black),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      NfButton(
                        label: 'Reproducir',
                        icon: Icons.play_arrow,
                        onTap: () => openPlayer(context, media),
                      ),
                      NfButton(
                        label: 'Más información',
                        icon: Icons.info_outline,
                        primary: false,
                        onTap: () => showDetail(context, media),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isDesktop)
            Positioned(
              right: 0,
              bottom: height * 0.2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 40, 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFDCDCDC), width: 3),
                  ),
                ),
                child: Text(
                  media.rating,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        pagePadding(MediaQuery.sizeOf(context).width),
        24,
        16,
        40,
      ),
      child: const Text(
        'Proyecto académico · Laboratorio Semana 10. Sin fines comerciales y sin relación con Netflix, Inc.',
        style: TextStyle(fontSize: 12, color: NfColors.textDim),
      ),
    );
  }
}
