import 'package:flutter/material.dart';

import '../models/media.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/poster_art.dart';
import 'player_screen.dart';

Future<void> showDetail(BuildContext context, Media media) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => _DetailModal(media: media),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _DetailModal extends StatefulWidget {
  const _DetailModal({required this.media});

  final Media media;

  @override
  State<_DetailModal> createState() => _DetailModalState();
}

class _DetailModalState extends State<_DetailModal> {
  int _season = 1;

  void _openOther(Media other) {
    final navigator = Navigator.of(context);
    navigator.pop();
    showDetail(navigator.context, other);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final media = widget.media;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= kDesktopBreakpoint;
    final width = isDesktop ? 850.0.clamp(0.0, size.width - 32) : size.width;
    final pad = isDesktop ? 40.0 : 16.0;
    final inList = state.inMyList(media);
    final liked = state.isLiked(media);
    final watched = state.progressOf(media) > 0;

    return Align(
      alignment: isDesktop ? Alignment.topCenter : Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: isDesktop ? 28 : 0),
        child: Material(
          color: NfColors.surface,
          borderRadius: BorderRadius.circular(isDesktop ? 8 : 0),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: width,
            height: isDesktop ? size.height - 28 : size.height,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: width * 9 / 16,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterArt(media: media, showTitle: false),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.5, 1],
                            colors: [Colors.transparent, NfColors.surface],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: CircleAction(
                          icon: Icons.close,
                          tooltip: 'Cerrar',
                          size: 36,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Positioned(
                        left: pad,
                        right: pad,
                        bottom: 22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              media.title,
                              style: displayStyle(
                                size: isDesktop ? 56 : 34,
                                shadows: const [
                                  Shadow(blurRadius: 12, color: Colors.black),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (media.comingSoon)
                                  const Text(
                                    'Próximamente',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else
                                  NfButton(
                                    label: watched ? 'Reanudar' : 'Reproducir',
                                    icon: Icons.play_arrow,
                                    compact: true,
                                    onTap: () => openPlayer(context, media),
                                  ),
                                const SizedBox(width: 10),
                                CircleAction(
                                  icon: inList ? Icons.check : Icons.add,
                                  tooltip: inList
                                      ? 'Quitar de Mi lista'
                                      : 'Agregar a Mi lista',
                                  size: 38,
                                  onTap: () => state.toggleMyList(media),
                                ),
                                const SizedBox(width: 8),
                                CircleAction(
                                  icon: liked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  tooltip: 'Me gusta',
                                  size: 38,
                                  onTap: () => state.toggleLiked(media),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Info(media: media, isDesktop: isDesktop),
                      if (media.isSeries && !media.comingSoon) ...[
                        const SizedBox(height: 32),
                        _Episodes(
                          media: media,
                          season: _season,
                          onSeason: (s) => setState(() => _season = s),
                        ),
                      ],
                      const SizedBox(height: 32),
                      const Text(
                        'Más títulos similares a este',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Similar(media: media, onOpen: _openOther),
                      const SizedBox(height: 32),
                      Text(
                        'Acerca de ${media.title}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Fact('Elenco', media.cast.join(', ')),
                      _Fact('Géneros', media.genres.join(', ')),
                      _Fact('Clasificación', media.rating),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.media, required this.isDesktop});

  final Media media;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final synopsis = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${media.match}% para ti',
              style: const TextStyle(
                color: NfColors.match,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text('${media.year}'),
            MaturityBadge(media.rating),
            Text(media.durationLabel),
            const MaturityBadge('HD'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          media.synopsis,
          style: const TextStyle(fontSize: 15, height: 1.45),
        ),
      ],
    );
    final facts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Fact('Elenco', media.cast.join(', ')),
        _Fact('Géneros', media.genres.join(', ')),
      ],
    );
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [synopsis, const SizedBox(height: 14), facts],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: synopsis),
        const SizedBox(width: 28),
        Expanded(child: facts),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 13, height: 1.35),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: NfColors.textDim),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _Episodes extends StatelessWidget {
  const _Episodes({
    required this.media,
    required this.season,
    required this.onSeason,
  });

  final Media media;
  final int season;
  final ValueChanged<int> onSeason;

  @override
  Widget build(BuildContext context) {
    final episodes = media.episodesFor(season);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Episodios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (media.seasons > 1)
              DropdownButton<int>(
                value: season,
                dropdownColor: NfColors.surfaceHigh,
                underline: const SizedBox.shrink(),
                items: [
                  for (var s = 1; s <= media.seasons; s++)
                    DropdownMenuItem(value: s, child: Text('Temporada $s')),
                ],
                onChanged: (s) {
                  if (s != null) onSeason(s);
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final episode in episodes)
          _EpisodeTile(media: media, season: season, episode: episode),
      ],
    );
  }
}

class _EpisodeTile extends StatefulWidget {
  const _EpisodeTile({
    required this.media,
    required this.season,
    required this.episode,
  });

  final Media media;
  final int season;
  final Episode episode;

  @override
  State<_EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<_EpisodeTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    final isNarrow = MediaQuery.sizeOf(context).width < 520;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => openPlayer(
          context,
          widget.media,
          season: widget.season,
          episode: episode,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hover ? NfColors.surfaceHigh : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: Color(0xFF404040)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isNarrow) ...[
                SizedBox(
                  width: 28,
                  child: Text(
                    '${episode.number}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: NfColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              SizedBox(
                width: isNarrow ? 104 : 130,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PosterArt(media: widget.media, showTitle: false),
                        if (_hover)
                          const Icon(Icons.play_circle_outline, size: 38),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isNarrow
                                ? '${episode.number}. ${episode.title}'
                                : episode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${episode.minutes} min',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      episode.synopsis,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: NfColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Similar extends StatelessWidget {
  const _Similar({required this.media, required this.onOpen});

  final Media media;
  final ValueChanged<Media> onOpen;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.similarTo(media);
    final columns = MediaQuery.sizeOf(context).width < 620 ? 2 : 3;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onOpen(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: NfColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: PosterArt(media: item),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${item.match}%',
                                      style: const TextStyle(
                                        color: NfColors.match,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    MaturityBadge(item.rating),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.year}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.synopsis,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: NfColors.textMuted,
                                  ),
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
          ],
        );
      },
    );
  }
}
