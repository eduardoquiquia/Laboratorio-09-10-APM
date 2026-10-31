import 'package:flutter/material.dart';

import '../models/media.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/title_card.dart';
import '../widgets/title_row.dart';

/// Altura reservada para la barra superior, que flota sobre el contenido.
const double _topInset = 110;

class TitleGrid extends StatelessWidget {
  const TitleGrid({
    super.key,
    required this.items,
    this.header,
    this.emptyMessage = 'No hay títulos para mostrar.',
  });

  final List<Media> items;
  final Widget? header;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final columns = width >= 1400
        ? 6
        : width >= 1000
            ? 5
            : width >= kDesktopBreakpoint
                ? 4
                : 2;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, _topInset, pad, 20),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: header ?? const SizedBox.shrink(),
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Center(
                child: Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: NfColors.textMuted),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 0, pad, 40),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 28,
                crossAxisSpacing: 8,
                childAspectRatio: 16 / 9,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  TitleCard(media: items[index]),
            ),
          ),
      ],
    );
  }
}

class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return TitleGrid(
      items: state.myList,
      header: const Text(
        'Mi lista',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      ),
      emptyMessage:
          'Todavía no agregaste títulos. Usa el botón + en cualquier título.',
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hasQuery = query.trim().isNotEmpty;
    return TitleGrid(
      items: hasQuery ? state.search(query) : state.visible,
      header: Text(
        hasQuery ? 'Resultados para "${query.trim()}"' : 'Explora el catálogo',
        style: const TextStyle(fontSize: 18, color: NfColors.textMuted),
      ),
      emptyMessage:
          'Tu búsqueda de "${query.trim()}" no tuvo coincidencias. Prueba con un título, una persona o un género.',
    );
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(top: _topInset),
      children: [
        TitleRow(title: 'Novedades en Netflix', items: state.newReleases),
        Top10Row(
          title: 'Las 10 series más populares hoy',
          items: state.top10(MediaType.series),
        ),
        Top10Row(
          title: 'Las 10 películas más populares hoy',
          items: state.top10(MediaType.movie),
        ),
        TitleRow(title: 'Próximamente', items: state.comingSoon),
      ],
    );
  }
}
