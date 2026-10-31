import 'package:flutter/material.dart';

enum MediaType { series, movie }

class Episode {
  const Episode({
    required this.number,
    required this.title,
    required this.synopsis,
    required this.minutes,
  });

  final int number;
  final String title;
  final String synopsis;
  final int minutes;
}

class Media {
  const Media({
    required this.id,
    required this.title,
    required this.type,
    required this.year,
    required this.rating,
    required this.genres,
    required this.synopsis,
    required this.cast,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.runtimeMinutes,
    this.seasons = 1,
    this.isOriginal = true,
    this.isNew = false,
    this.comingSoon = false,
    this.topRank,
    this.match = 95,
  });

  final String id;
  final String title;
  final MediaType type;
  final int year;
  final String rating;
  final List<String> genres;
  final String synopsis;
  final List<String> cast;
  final Color primary;
  final Color secondary;
  final Color accent;

  /// Duración de la película o de un episodio promedio.
  final int runtimeMinutes;
  final int seasons;
  final bool isOriginal;
  final bool isNew;
  final bool comingSoon;
  final int? topRank;
  final int match;

  bool get isSeries => type == MediaType.series;

  /// Las clasificaciones aptas para el perfil infantil.
  bool get isKidFriendly => rating == 'TP' || rating == '7+';

  /// Hash estable entre ejecuciones (String.hashCode no lo es).
  int get seed => id.codeUnits.fold(7, (acc, c) => (acc * 31 + c) & 0x7fffffff);

  String get durationLabel {
    if (isSeries) {
      return seasons == 1 ? '1 temporada' : '$seasons temporadas';
    }
    final h = runtimeMinutes ~/ 60;
    final m = runtimeMinutes % 60;
    return h == 0 ? '$m min' : '$h h $m min';
  }

  List<Episode> episodesFor(int season) {
    const names = [
      'El comienzo',
      'Lo que quedó atrás',
      'Sin retorno',
      'Puntos ciegos',
      'La otra versión',
      'Bajo la superficie',
      'Cuenta regresiva',
      'El último acuerdo',
    ];
    const plots = [
      'Una decisión inesperada lo cambia todo y obliga a todos a mostrar sus cartas.',
      'Un secreto del pasado sale a la luz justo cuando parecía que todo estaba bajo control.',
      'Las alianzas se quiebran mientras el tiempo para actuar se agota.',
      'Una pista falsa desvía la búsqueda y alguien de confianza empieza a dudar.',
      'Dos versiones de la misma historia se enfrentan y solo una puede ser verdad.',
      'Lo que nadie quería ver finalmente aparece y ya no hay forma de ignorarlo.',
      'Con todo en contra, el grupo apuesta por un plan desesperado.',
      'Todo converge en una noche que nadie va a olvidar.',
    ];
    return List.generate(names.length, (i) {
      final k = (i + season - 1) % names.length;
      return Episode(
        number: i + 1,
        title: names[k],
        synopsis: plots[k],
        minutes: runtimeMinutes + ((seed + i * 3) % 9) - 4,
      );
    });
  }
}
