import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/media.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/poster_art.dart';

Future<void> openPlayer(
  BuildContext context,
  Media media, {
  int season = 1,
  Episode? episode,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => PlayerScreen(
        media: media,
        season: season,
        episode: episode ?? (media.isSeries ? media.episodesFor(1).first : null),
      ),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// Reproductor simulado: no hay video real, pero el tiempo, los controles y
/// el avance guardado en "Continuar viendo" funcionan de verdad.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.media,
    required this.season,
    this.episode,
  });

  final Media media;
  final int season;
  final Episode? episode;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  static const _skip = 10;

  late final int _total = (widget.episode?.minutes ?? widget.media.runtimeMinutes) * 60;
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat(reverse: true);

  Timer? _clock;
  Timer? _hideTimer;
  int _position = 0;
  bool _playing = true;
  bool _muted = false;
  bool _controlsVisible = true;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _showControls();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _position = (AppScope.read(context).progressOf(widget.media) * _total).round();
  }

  @override
  void dispose() {
    _clock?.cancel();
    _hideTimer?.cancel();
    _drift.dispose();
    super.dispose();
  }

  void _tick() {
    if (!_playing) return;
    if (_position >= _total) {
      _exit();
      return;
    }
    setState(() => _position++);
  }

  void _showControls() {
    _hideTimer?.cancel();
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _playing) setState(() => _controlsVisible = false);
    });
  }

  void _togglePlay() {
    setState(() {
      _playing = !_playing;
      _playing ? _drift.repeat(reverse: true) : _drift.stop();
    });
    _showControls();
  }

  void _seek(int seconds) {
    setState(() => _position = (_position + seconds).clamp(0, _total));
    _showControls();
  }

  void _exit() => Navigator.of(context).maybePop();

  String _format(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  String get _heading {
    final episode = widget.episode;
    if (episode == null) return widget.media.title;
    return '${widget.media.title}  T${widget.season}:E${episode.number} "${episode.title}"';
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          AppScope.read(context).saveProgress(media, _position / _total);
        }
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.space): _togglePlay,
          const SingleActivator(LogicalKeyboardKey.keyK): _togglePlay,
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _seek(_skip),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _seek(-_skip),
          const SingleActivator(LogicalKeyboardKey.keyM): () =>
              setState(() => _muted = !_muted),
          const SingleActivator(LogicalKeyboardKey.escape): _exit,
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: MouseRegion(
              onHover: (_) => _showControls(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePlay,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.02, end: 1.16).animate(_drift),
                        child: PosterArt(media: media, showTitle: false),
                      ),
                    ),
                    if (!_playing)
                      Container(color: Colors.black.withValues(alpha: 0.4)),
                    AnimatedOpacity(
                      opacity: _controlsVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: IgnorePointer(
                        ignoring: !_controlsVisible,
                        child: _controls(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls() {
    final remaining = _total - _position;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.25, 0.7, 1],
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Volver',
                  iconSize: 34,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _exit,
                ),
              ),
              const Spacer(),
              if (!_playing)
                const Icon(Icons.pause_circle_outline, size: 84),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: NfColors.red,
                        inactiveTrackColor: const Color(0xFF5A5A5A),
                        thumbColor: NfColors.red,
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _position.clamp(0, _total).toDouble(),
                        max: _total.toDouble(),
                        onChanged: (value) {
                          setState(() => _position = value.round());
                          _showControls();
                        },
                      ),
                    ),
                  ),
                  Text(_format(remaining)),
                ],
              ),
              Row(
                children: [
                  _ControlButton(
                    icon: _playing ? Icons.pause : Icons.play_arrow,
                    tooltip: _playing ? 'Pausar' : 'Reproducir',
                    onTap: _togglePlay,
                  ),
                  _ControlButton(
                    icon: Icons.replay_10,
                    tooltip: 'Retroceder 10 segundos',
                    onTap: () => _seek(-_skip),
                  ),
                  _ControlButton(
                    icon: Icons.forward_10,
                    tooltip: 'Adelantar 10 segundos',
                    onTap: () => _seek(_skip),
                  ),
                  _ControlButton(
                    icon: _muted ? Icons.volume_off : Icons.volume_up,
                    tooltip: _muted ? 'Activar sonido' : 'Silenciar',
                    onTap: () => setState(() => _muted = !_muted),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _heading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      iconSize: 32,
      icon: Icon(icon),
      onPressed: onTap,
    );
  }
}
