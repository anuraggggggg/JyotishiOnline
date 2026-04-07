// lib/widgets/gift_animation_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// Call [GiftAnimationOverlay.show] right after a gift is successfully sent.
/// It inserts a full-screen overlay of floating emojis + confetti that removes
/// itself automatically once the animation completes (~2.4 s).
class GiftAnimationOverlay {
  static OverlayEntry? _entry;

  static void show(
      BuildContext context, {
        required String giftEmoji,
        int qty = 1,
      }) {
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _GiftAnimWidget(
        emoji: giftEmoji,
        qty: qty,
        onDone: () {
          entry.remove();
          if (_entry == entry) _entry = null;
        },
      ),
    );

    _entry = entry;
    overlay.insert(entry);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal widget
// ─────────────────────────────────────────────────────────────────────────────

class _GiftAnimWidget extends StatefulWidget {
  final String emoji;
  final int qty;
  final VoidCallback onDone;

  const _GiftAnimWidget({
    required this.emoji,
    required this.qty,
    required this.onDone,
  });

  @override
  State<_GiftAnimWidget> createState() => _GiftAnimWidgetState();
}

class _GiftAnimWidgetState extends State<_GiftAnimWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final Random _rng = Random();

  late final List<_ConfettiParticle> _confetti;
  late final List<_FloatingEmoji> _emojis;

  static const _colors = [
    Color(0xFF7C6FF7),
    Color(0xFFFFD700),
    Color(0xFFFF6B9D),
    Color(0xFF4ECFFF),
    Color(0xFFFF8C00),
    Color(0xFF4CAF50),
    Color(0xFFFF3B6B),
    Color(0xFF00D4AA),
  ];

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward().whenComplete(widget.onDone);

    // Generate 44 confetti pieces
    _confetti = List.generate(44, (_) => _ConfettiParticle(
      startX: 0.05 + _rng.nextDouble() * 0.90,
      delay: _rng.nextDouble() * 0.28,
      color: _colors[_rng.nextInt(_colors.length)],
      size: 6.0 + _rng.nextDouble() * 9.0,
      vx: (_rng.nextDouble() - 0.5) * 0.55,
      vy: 0.35 + _rng.nextDouble() * 0.50,
      rotStart: _rng.nextDouble() * pi * 2,
      rotSpeed: (_rng.nextDouble() - 0.5) * 14.0,
      isCircle: _rng.nextBool(),
    ));

    // Floating emoji count capped at 10
    final count = min(widget.qty * 2, 10);
    _emojis = List.generate(count, (i) => _FloatingEmoji(
      startX: 0.15 + _rng.nextDouble() * 0.70,
      delay: i * 0.06 + _rng.nextDouble() * 0.04,
      riseRatio: 0.40 + _rng.nextDouble() * 0.25,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          return Stack(children: [
            // ── Confetti ────────────────────────────────────────────────
            ..._confetti.map((p) {
              final raw = t - p.delay;
              if (raw <= 0) return const SizedBox.shrink();
              final pt = (raw / (1.0 - p.delay)).clamp(0.0, 1.0);
              final opacity = pt < 0.75 ? 1.0 : Curves.easeIn.transform((1.0 - pt) / 0.25);

              final x = p.startX * size.width + p.vx * pt * size.width * 0.45;
              final y = size.height * 0.12 + p.vy * pt * size.height * 0.62;

              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: p.rotStart + p.rotSpeed * pt,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: p.color,
                        borderRadius: p.isCircle
                            ? BorderRadius.circular(p.size)
                            : BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // ── Floating emojis ──────────────────────────────────────────
            ..._emojis.map((e) {
              final raw = t - e.delay;
              if (raw <= 0) return const SizedBox.shrink();
              final pt = (raw / (1.0 - e.delay)).clamp(0.0, 1.0);

              // Fade out in final 30 %
              final opacity = pt < 0.70 ? 1.0 : Curves.easeOut.transform((1.0 - pt) / 0.30);

              // Scale: grow then shrink
              final scale = 0.6 + sin(pt * pi) * 0.7;

              final y = size.height * 0.78 - pt * size.height * e.riseRatio;

              return Positioned(
                left: e.startX * size.width - 20,
                top: y,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              );
            }),
          ]);
        },
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _ConfettiParticle {
  final double startX, delay, vx, vy, size, rotStart, rotSpeed;
  final Color color;
  final bool isCircle;

  const _ConfettiParticle({
    required this.startX,
    required this.delay,
    required this.color,
    required this.size,
    required this.vx,
    required this.vy,
    required this.rotStart,
    required this.rotSpeed,
    required this.isCircle,
  });
}

class _FloatingEmoji {
  final double startX, delay, riseRatio;
  const _FloatingEmoji({
    required this.startX,
    required this.delay,
    required this.riseRatio,
  });
}