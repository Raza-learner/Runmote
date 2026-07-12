import 'package:flutter/material.dart';

class ChatSkeleton extends StatefulWidget {
  const ChatSkeleton({super.key});

  @override
  State<ChatSkeleton> createState() => _ChatSkeletonState();
}

class _ChatSkeletonState extends State<ChatSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.6).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final radius = BorderRadius.circular(12);

    return Semantics(
      label: 'Chat loading skeleton',
      liveRegion: true,
      child: FadeTransition(
        opacity: _opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bubble(base, radius, 0.7, align: Alignment.centerRight),
              const SizedBox(height: 8),
              _bubble(base, radius, 0.5),
              const SizedBox(height: 8),
              _bubble(base, radius, 0.85),
              const SizedBox(height: 8),
              _bubble(base, radius, 0.6, align: Alignment.centerRight),
              const SizedBox(height: 8),
              _bubble(base, radius, 0.35),
              const SizedBox(height: 8),
              _bubble(base, radius, 0.75, align: Alignment.centerRight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(Color base, BorderRadius radius, double widthFraction,
      {AlignmentGeometry align = Alignment.centerLeft}) {
    return Align(
      alignment: align,
      child: Container(
        width: MediaQuery.of(context).size.width * widthFraction,
        height: 36,
        decoration: BoxDecoration(
          color: base,
          borderRadius: radius,
        ),
      ),
    );
  }
}
