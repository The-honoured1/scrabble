import 'dart:math' as math;

import 'package:flutter/material.dart';

class MeshBackground extends StatefulWidget {
  const MeshBackground({super.key});

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A18),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GlowOrb(
                alignment: Alignment(-0.85 + (t * 0.25), -0.95 + (t * 0.08)),
                color: const Color(0xFF26463B),
                size: 260,
              ),
              _GlowOrb(
                alignment: Alignment(0.9 - (t * 0.15), -0.3 + (t * 0.12)),
                color: const Color(0xFF2D263C),
                size: 320,
              ),
              _GlowOrb(
                alignment: Alignment(
                  -0.2 + math.sin(t * math.pi) * 0.22,
                  0.9 - (t * 0.18),
                ),
                color: const Color(0xFF312B1E),
                size: 360,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.015),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.34),
                color.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
