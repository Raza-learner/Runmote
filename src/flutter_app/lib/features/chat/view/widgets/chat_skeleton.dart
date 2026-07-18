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
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.55, end: 0.9).animate(_controller);
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
              _MessageRow(base, isUser: true, widthFactor: 0.72, lines: 1),
              const SizedBox(height: 12),
              _MessageRow(base, isUser: false, widthFactor: 0.85, lines: 2),
              const SizedBox(height: 12),
              _MessageRow(base, isUser: false, widthFactor: 0.62, lines: 1),
              const SizedBox(height: 12),
              _MessageRow(base, isUser: true, widthFactor: 0.55, lines: 1),
              const SizedBox(height: 12),
              _MessageRow(base, isUser: false, widthFactor: 0.78, lines: 3),
              const SizedBox(height: 12),
              _MessageRow(base, isUser: false, widthFactor: 0.45, lines: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final Color base;
  final bool isUser;
  final double widthFactor;
  final int lines;

  const _MessageRow(this.base, {
    required this.isUser,
    required this.widthFactor,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: base,
        shape: BoxShape.circle,
      ),
    );

    final bubble = Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * widthFactor,
          height: 14.0 * lines + 16,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: isUser
          ? [Flexible(child: bubble), const SizedBox(width: 8), avatar]
          : [avatar, const SizedBox(width: 8), Flexible(child: bubble)],
    );
  }
}
