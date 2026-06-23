import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedGradientBg extends StatefulWidget {
  final Widget child;
  final List<Color> colors;

  const AnimatedGradientBg({
    super.key,
    required this.child,
    this.colors = const [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
  });

  @override
  State<AnimatedGradientBg> createState() => _AnimatedGradientBgState();
}

class _AnimatedGradientBgState extends State<AnimatedGradientBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

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
        final angle = t * 2 * math.pi;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.5 * math.cos(angle), 0.5 * math.sin(angle)),
              end: Alignment(-0.5 * math.cos(angle), -0.5 * math.sin(angle)),
              colors: widget.colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
