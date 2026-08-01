import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showGrid = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColors = isDark
        ? [
            const Color(0xFF020617), // Deep slate black
            const Color(0xFF0F172A), // Dark slate blue
            const Color(0xFF1E293B), // Slate blue
          ]
        : [
            const Color(0xFFF9F7F2),
            const Color(0xFFF2EFE9),
            const Color(0xFFEBE7DF)
          ];

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgColors,
            ),
          ),
        ),
        if (widget.showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(isDark: isDark),
            ),
          ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: -150 +
                      (ui.lerpDouble(0, 100,
                              Curves.easeInOut.transform(_controller.value)) ??
                          0),
                  right: -100 +
                      (ui.lerpDouble(
                              0,
                              80,
                              Curves.easeInOut.transform(
                                  (_controller.value + 0.5) % 1.0)) ??
                          0),
                  child: _BlurCircle(
                    color: const Color(0xFF6366F1)
                        .withValues(alpha: isDark ? 0.08 : 0.04),
                    size: 500,
                  ),
                ),
                Positioned(
                  bottom: -120 +
                      (ui.lerpDouble(0, 100,
                              Curves.easeInOut.transform(
                                  (_controller.value + 0.3) % 1.0)) ??
                          0),
                  left: -150 +
                      (ui.lerpDouble(0, 120,
                              Curves.easeInOut.transform(
                                  (_controller.value + 0.8) % 1.0)) ??
                          0),
                  child: _BlurCircle(
                    color: const Color(0xFFA855F7)
                        .withValues(alpha: isDark ? 0.08 : 0.04),
                    size: 450,
                  ),
                ),
              ],
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    // Radial gradient approximates a heavily blurred circle (sigma 100)
    // but costs a fraction of a real ImageFilter blur, which would be
    // re-rasterized every frame of the animation.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [color.withValues(alpha: 1.0), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool isDark;

  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black)
          .withValues(alpha: isDark ? 0.03 : 0.02)
      ..strokeWidth = 0.5;

    const double spacing = 50.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Add subtle dots at intersections
    final dotPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black)
          .withValues(alpha: isDark ? 0.05 : 0.03)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
