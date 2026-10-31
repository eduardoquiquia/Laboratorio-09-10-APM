import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

/// Pantalla "¿Quién está viendo ahora?". Reemplaza al inicio de sesión:
/// la app no pide ni guarda correos ni contraseñas.
class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  static const _maxProfiles = 5;

  bool _managing = false;

  void _enter(Profile profile) {
    AppScope.read(context).selectProfile(profile);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const HomeShell(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }

  Future<String?> _askName(String title, String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NfColors.surfaceHigh,
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 16,
          decoration: const InputDecoration(hintText: 'Nombre'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(Profile profile) async {
    final state = AppScope.read(context);
    final name = (await _askName('Editar perfil', profile.name))?.trim();
    if (name != null && name.isNotEmpty) state.renameProfile(profile, name);
  }

  Future<void> _add() async {
    final state = AppScope.read(context);
    final name = (await _askName('Agregar perfil', ''))?.trim();
    if (name != null && name.isNotEmpty) state.addProfile(name);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= kDesktopBreakpoint;
    final avatarSize = isDesktop ? 140.0 : 92.0;
    return Scaffold(
      backgroundColor: NfColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pagePadding(width), 18, 0, 0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: NetflixLogo(size: 34),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _managing
                            ? 'Administrar perfiles:'
                            : '¿Quién está viendo ahora?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 46 : 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isDesktop ? 28 : 18,
                        runSpacing: 24,
                        children: [
                          for (final profile in state.profiles)
                            _ProfileTile(
                              label: profile.name,
                              size: avatarSize,
                              editing: _managing,
                              onTap: () => _managing
                                  ? _rename(profile)
                                  : _enter(profile),
                              child: ProfileAvatar(
                                color: profile.color,
                                size: avatarSize,
                              ),
                            ),
                          if (state.profiles.length < _maxProfiles)
                            _ProfileTile(
                              label: 'Agregar perfil',
                              size: avatarSize,
                              onTap: _add,
                              child: SizedBox.square(
                                dimension: avatarSize,
                                child: Icon(
                                  Icons.add_circle,
                                  size: avatarSize * 0.55,
                                  color: NfColors.textDim,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 44),
                      OutlinedButton(
                        onPressed: () =>
                            setState(() => _managing = !_managing),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _managing
                              ? Colors.black
                              : NfColors.textMuted,
                          backgroundColor:
                              _managing ? Colors.white : Colors.transparent,
                          side: const BorderSide(color: NfColors.textDim),
                          shape: const RoundedRectangleBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          _managing ? 'Listo' : 'Administrar perfiles',
                          style: const TextStyle(letterSpacing: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatefulWidget {
  const _ProfileTile({
    required this.label,
    required this.size,
    required this.onTap,
    required this.child,
    this.editing = false,
  });

  final String label;
  final double size;
  final VoidCallback onTap;
  final Widget child;
  final bool editing;

  @override
  State<_ProfileTile> createState() => _ProfileTileState();
}

class _ProfileTileState extends State<_ProfileTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.size + 8,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color: _hover ? Colors.white : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    widget.child,
                    if (widget.editing) ...[
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                      Icon(Icons.edit, size: widget.size * 0.28),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.size > 100 ? 18 : 14,
                  color: _hover ? Colors.white : NfColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
