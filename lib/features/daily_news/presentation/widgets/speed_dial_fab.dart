import 'package:flutter/material.dart';

class SpeedDialFab extends StatefulWidget {
  const SpeedDialFab({
    super.key,
    required this.onProfile,
    required this.onPublish,
  });

  final VoidCallback onProfile;
  final VoidCallback onPublish;

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  static const double _kFabSize = 56;
  static const EdgeInsets _kMargin = EdgeInsets.all(16);
  static const Duration _kDuration = Duration(milliseconds: 220);

  OverlayEntry? _entry;
  late final AnimationController _ctrl;

  // le tengo que pone Cooldown para evitar spam

  DateTime _nextAllowedToggle = DateTime.fromMillisecondsSinceEpoch(0);

  bool get _isOpen => _entry != null;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _kDuration);
  }

  @override
  void dispose() {
    _removeOverlay(immediate: true);
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    final now = DateTime.now();

    //  cooldown 0,5

    if (now.isBefore(_nextAllowedToggle)) return;

    // no permitir toggle mientras anima
    if (_ctrl.isAnimating) return;

    _nextAllowedToggle = now.add(const Duration(milliseconds: 500));

    _isOpen ? _removeOverlay() : _showOverlay();
  }

  void _showOverlay() {
    if (_isOpen || _ctrl.isAnimating) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (_) {
        final fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
        final scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);

        return Stack(
          children: [

            // Tap afuera para cerrar (pero deja scrollear)

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.expand(),
              ),
            ),

            // Menu abajo a la derecha

            Positioned(
              right: _kMargin.right,
              bottom: _kMargin.bottom,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FadeTransition(
                      opacity: fade,
                      child: ScaleTransition(
                        scale: scale,
                        child: _ActionChip(
                          label: 'Post',
                          icon: Icons.edit,
                          onTap: () {
                            _removeOverlay();
                            widget.onPublish();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: fade,
                      child: ScaleTransition(
                        scale: scale,
                        child: _ActionChip(
                          label: 'My Profile',
                          icon: Icons.person,
                          onTap: () {
                            _removeOverlay();
                            widget.onProfile();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _MainFab(controller: _ctrl, onPressed: _toggle),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    _ctrl.forward(from: 0);
    setState(() {});
  }

  void _removeOverlay({bool immediate = false}) {
    if (!_isOpen) return;

    final entry = _entry;
    _entry = null;

    if (immediate) {
      entry?.remove();
      return;
    }

    if (_ctrl.isAnimating) return;

    _ctrl.reverse().whenComplete(() {
      entry?.remove();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    // mientras el overlay esta abierto ocultamos el FAB “base” para que no haya duplicados

    if (_isOpen) {
      return const SizedBox(width: _kFabSize, height: _kFabSize);
    }

    return _MainFab(controller: _ctrl, onPressed: _toggle);
  }
}

class _MainFab extends StatelessWidget {
  const _MainFab({
    required this.controller,
    required this.onPressed,
  });

  final AnimationController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      elevation: 0,
      highlightElevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.black12),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final t = controller.value;
          return Transform.rotate(
            angle: t * 0.75,
            child: const Icon(Icons.add, color: Colors.black),
          );
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
