import 'package:flutter/material.dart';

import '../models/media.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'browse_page.dart';
import 'collection_pages.dart';
import 'profiles_screen.dart';

enum NavTab { home, series, movies, news, myList }

const _tabLabels = {
  NavTab.home: 'Inicio',
  NavTab.series: 'Series',
  NavTab.movies: 'Películas',
  NavTab.news: 'Novedades populares',
  NavTab.myList: 'Mi lista',
};

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  NavTab _tab = NavTab.home;
  bool _scrolled = false;
  bool _searchOpen = false;

  String get _query => _searchController.text;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _select(NavTab tab) {
    setState(() {
      _tab = tab;
      _scrolled = false;
      _closeSearch();
    });
  }

  void _closeSearch() {
    _searchOpen = false;
    _searchController.clear();
  }

  void _toggleSearch() {
    setState(() {
      if (_searchOpen) {
        _closeSearch();
      } else {
        _searchOpen = true;
        _searchFocus.requestFocus();
      }
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final scrolled = notification.metrics.pixels > 8;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    return false;
  }

  Widget _page() {
    if (_searchOpen) return SearchPage(query: _query);
    return switch (_tab) {
      NavTab.home => const BrowsePage(key: ValueKey('home')),
      NavTab.series => const BrowsePage(
          key: ValueKey('series'),
          type: MediaType.series,
        ),
      NavTab.movies => const BrowsePage(
          key: ValueKey('movies'),
          type: MediaType.movie,
        ),
      NavTab.news => const NewsPage(),
      NavTab.myList => const MyListPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: _page(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              tab: _tab,
              solid: _scrolled || _searchOpen,
              isDesktop: isDesktop,
              searchOpen: _searchOpen,
              searchController: _searchController,
              searchFocus: _searchFocus,
              onSelect: _select,
              onToggleSearch: _toggleSearch,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBarTheme(
              data: const NavigationBarThemeData(
                backgroundColor: Colors.black,
                indicatorColor: Colors.transparent,
              ),
              child: NavigationBar(
                height: 62,
                selectedIndex: switch (_tab) {
                  NavTab.news => 1,
                  NavTab.myList => 2,
                  _ => 0,
                },
                onDestinationSelected: (i) => _select(
                  const [NavTab.home, NavTab.news, NavTab.myList][i],
                ),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.video_library_outlined),
                    selectedIcon: Icon(Icons.video_library),
                    label: 'Novedades',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_border),
                    selectedIcon: Icon(Icons.bookmark),
                    label: 'Mi lista',
                  ),
                ],
              ),
            ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.tab,
    required this.solid,
    required this.isDesktop,
    required this.searchOpen,
    required this.searchController,
    required this.searchFocus,
    required this.onSelect,
    required this.onToggleSearch,
  });

  final NavTab tab;
  final bool solid;
  final bool isDesktop;
  final bool searchOpen;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<NavTab> onSelect;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: pagePadding(width),
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: solid ? NfColors.background : null,
        gradient: solid
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => onSelect(NavTab.home),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: NetflixLogo(size: isDesktop ? 32 : 26),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final entry in _tabLabels.entries)
                            _NavLink(
                              label: entry.value,
                              selected: !searchOpen && entry.key == tab,
                              onTap: () => onSelect(entry.key),
                            ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                _SearchBox(
                  open: searchOpen,
                  expanded: isDesktop ? 240 : 150,
                  controller: searchController,
                  focusNode: searchFocus,
                  onToggle: onToggleSearch,
                ),
                const SizedBox(width: 14),
                const _ProfileMenu(),
              ],
            ),
            if (!isDesktop && !searchOpen) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _NavLink(
                    label: 'Series',
                    selected: tab == NavTab.series,
                    onTap: () => onSelect(NavTab.series),
                  ),
                  _NavLink(
                    label: 'Películas',
                    selected: tab == NavTab.movies,
                    onTap: () => onSelect(NavTab.movies),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
              color: widget.selected || _hover
                  ? Colors.white
                  : const Color(0xFFE5E5E5),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.open,
    required this.expanded,
    required this.controller,
    required this.focusNode,
    required this.onToggle,
  });

  final bool open;
  final double expanded;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: open ? expanded : 36,
      height: 36,
      decoration: BoxDecoration(
        color: open ? Colors.black.withValues(alpha: 0.8) : null,
        border: open ? Border.all(color: Colors.white) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: open ? 'Cerrar búsqueda' : 'Buscar',
              icon: Icon(open ? Icons.close : Icons.search, size: 22),
              onPressed: onToggle,
            ),
          ),
          if (open)
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                cursorColor: Colors.white,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Títulos, personas, géneros',
                  hintStyle: TextStyle(fontSize: 13, color: NfColors.textDim),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final current = state.current;
    if (current == null) return const SizedBox.shrink();
    return PopupMenuButton<Object>(
      tooltip: 'Cuenta',
      color: Colors.black.withValues(alpha: 0.92),
      position: PopupMenuPosition.under,
      onSelected: (value) {
        if (value is Profile) {
          state.selectProfile(value);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ProfilesScreen()),
            (_) => false,
          );
        }
      },
      itemBuilder: (context) => [
        for (final profile in state.profiles)
          if (profile != current)
            PopupMenuItem<Object>(
              value: profile,
              child: Row(
                children: [
                  ProfileAvatar(color: profile.color, size: 28),
                  const SizedBox(width: 10),
                  Text(profile.name, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
        const PopupMenuDivider(),
        const PopupMenuItem<Object>(
          value: 'manage',
          child: Text(
            'Administrar perfiles',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(color: current.color, size: 32),
          const Icon(Icons.arrow_drop_down, size: 22),
        ],
      ),
    );
  }
}
