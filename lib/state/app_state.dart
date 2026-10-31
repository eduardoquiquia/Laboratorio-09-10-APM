import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/media.dart';

class Profile {
  Profile({
    required this.name,
    required this.color,
    this.isKids = false,
    Map<String, double>? progress,
  }) : progress = progress ?? {};

  String name;
  final Color color;
  final bool isKids;
  final Set<String> myList = {};
  final Set<String> liked = {};

  /// Avance por título, de 0 a 1. Lo que aparece aquí es "Continuar viendo".
  final Map<String, double> progress;
}

class AppState extends ChangeNotifier {
  AppState({List<Media>? media}) : _media = media ?? catalog;

  final List<Media> _media;

  final List<Profile> profiles = [
    Profile(
      name: 'Usuario',
      color: const Color(0xFF0071EB),
      progress: {
        'codigo-sombra': 0.62,
        'punto-de-quiebre': 0.28,
        'casa-de-sal': 0.81,
      },
    ),
    Profile(name: 'Ana', color: const Color(0xFFE5A50A)),
    Profile(name: 'Invitado', color: const Color(0xFF2FB15C)),
    Profile(
      name: 'Niños',
      color: const Color(0xFFE5398D),
      isKids: true,
      progress: {'equipo-relampago': 0.4},
    ),
  ];

  static const _newProfileColors = [
    Color(0xFF8E44AD),
    Color(0xFF16A085),
    Color(0xFFD35400),
  ];

  Profile? current;

  void selectProfile(Profile profile) {
    current = profile;
    notifyListeners();
  }

  void addProfile(String name) {
    profiles.add(
      Profile(
        name: name,
        color: _newProfileColors[profiles.length % _newProfileColors.length],
      ),
    );
    notifyListeners();
  }

  void renameProfile(Profile profile, String name) {
    profile.name = name;
    notifyListeners();
  }

  /// Catálogo visible para el perfil activo, sin los próximos estrenos.
  List<Media> get visible => _media
      .where((m) => !m.comingSoon && _allowed(m))
      .toList(growable: false);

  bool _allowed(Media m) => !(current?.isKids ?? false) || m.isKidFriendly;

  List<Media> ofType(MediaType? type) =>
      visible.where((m) => type == null || m.type == type).toList();

  List<Media> get comingSoon =>
      _media.where((m) => m.comingSoon && _allowed(m)).toList();

  List<Media> get newReleases => visible.where((m) => m.isNew).toList();

  List<Media> top10([MediaType? type]) {
    final ranked = ofType(type).where((m) => m.topRank != null).toList()
      ..sort((a, b) => a.topRank!.compareTo(b.topRank!));
    return ranked;
  }

  List<Media> byGenre(String genre, [MediaType? type]) =>
      ofType(type).where((m) => m.genres.contains(genre)).toList();

  List<String> genres([MediaType? type]) {
    final all = ofType(type).expand((m) => m.genres).toSet().toList()..sort();
    return all;
  }

  Media byId(String id) => _media.firstWhere((m) => m.id == id);

  List<Media> get continueWatching {
    final p = current;
    if (p == null) return const [];
    return visible.where((m) => p.progress.containsKey(m.id)).toList();
  }

  List<Media> get myList {
    final p = current;
    if (p == null) return const [];
    return visible.where((m) => p.myList.contains(m.id)).toList();
  }

  bool inMyList(Media m) => current?.myList.contains(m.id) ?? false;
  bool isLiked(Media m) => current?.liked.contains(m.id) ?? false;
  double progressOf(Media m) => current?.progress[m.id] ?? 0;

  void toggleMyList(Media m) {
    final list = current?.myList;
    if (list == null) return;
    if (!list.remove(m.id)) list.add(m.id);
    notifyListeners();
  }

  void toggleLiked(Media m) {
    final set = current?.liked;
    if (set == null) return;
    if (!set.remove(m.id)) set.add(m.id);
    notifyListeners();
  }

  /// Guarda el avance; al terminar el título sale de "Continuar viendo".
  void saveProgress(Media m, double value) {
    final p = current;
    if (p == null) return;
    if (value >= 0.97) {
      p.progress.remove(m.id);
    } else if (value > 0.005) {
      p.progress[m.id] = value;
    }
    notifyListeners();
  }

  /// Títulos que comparten más géneros con [m].
  List<Media> similarTo(Media m, {int limit = 6}) {
    int score(Media o) => o.genres.where(m.genres.contains).length;
    final others = visible.where((o) => o.id != m.id && score(o) > 0).toList()
      ..sort((a, b) => score(b).compareTo(score(a)));
    return others.take(limit).toList();
  }

  List<Media> search(String query) {
    final q = normalize(query.trim());
    if (q.isEmpty) return const [];
    return visible.where((m) {
      final text = normalize([m.title, ...m.genres, ...m.cast].join(' '));
      return text.contains(q);
    }).toList();
  }

  /// Minúsculas y sin acentos, para que "orbita" encuentre "Órbita".
  static String normalize(String text) {
    const map = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    return text.toLowerCase().split('').map((c) => map[c] ?? c).join();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Lectura sin suscribirse, para usar dentro de callbacks.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
