import 'package:flutter_test/flutter_test.dart';
import 'package:netflix_clone/data/catalog.dart';
import 'package:netflix_clone/models/media.dart';
import 'package:netflix_clone/state/app_state.dart';

void main() {
  late AppState state;

  setUp(() {
    state = AppState();
    state.selectProfile(state.profiles.first);
  });

  test('los ids del catálogo son únicos', () {
    final ids = catalog.map((m) => m.id).toSet();
    expect(ids.length, catalog.length);
  });

  test('el Top 10 sale ordenado y sin próximos estrenos', () {
    final top = state.top10();
    expect(top.length, 10);
    expect(top.map((m) => m.topRank), List.generate(10, (i) => i + 1));
    expect(state.visible.any((m) => m.comingSoon), isFalse);
  });

  test('el perfil Niños solo ve títulos aptos', () {
    state.selectProfile(state.profiles.firstWhere((p) => p.isKids));
    expect(state.visible, isNotEmpty);
    expect(state.visible.every((m) => m.isKidFriendly), isTrue);
    expect(state.comingSoon.every((m) => m.isKidFriendly), isTrue);
  });

  test('Mi lista agrega, quita y es propia de cada perfil', () {
    final media = state.visible.first;
    state.toggleMyList(media);
    expect(state.myList, contains(media));

    state.selectProfile(state.profiles[1]);
    expect(state.myList, isEmpty);

    state.selectProfile(state.profiles.first);
    state.toggleMyList(media);
    expect(state.myList, isEmpty);
  });

  test('terminar un título lo saca de Continuar viendo', () {
    final media = state.byId('codigo-sombra');
    expect(state.continueWatching, contains(media));
    state.saveProgress(media, 0.5);
    expect(state.progressOf(media), 0.5);
    state.saveProgress(media, 1);
    expect(state.continueWatching, isNot(contains(media)));
  });

  test('la búsqueda ignora acentos y mayúsculas', () {
    expect(state.search('ORBITA').map((m) => m.id), contains('orbita-cero'));
    expect(state.search('terror'), isNotEmpty);
    expect(state.search('xyz123'), isEmpty);
    expect(state.search('   '), isEmpty);
  });

  test('similares comparte género y excluye al propio título', () {
    final media = state.byId('el-ultimo-faro');
    final similar = state.similarTo(media);
    expect(similar, isNot(contains(media)));
    expect(
      similar.every((m) => m.genres.any(media.genres.contains)),
      isTrue,
    );
  });

  test('las películas y series muestran su duración correcta', () {
    final movie = state.ofType(MediaType.movie).first;
    expect(movie.durationLabel, contains('h'));
    final series = state.byId('casa-de-sal');
    expect(series.durationLabel, '4 temporadas');
    expect(series.episodesFor(1).length, 8);
  });
}
