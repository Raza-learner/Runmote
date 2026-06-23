import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AgentStatus { online, offline, connecting }

class StatusBadge extends StatelessWidget {
  final AgentStatus status;
  final double size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedDot(
      size: size,
      color: switch (status) {
        AgentStatus.online => AppColors.online,
        AgentStatus.offline => AppColors.offline,
        AgentStatus.connecting => AppColors.connecting,
      },
    );
  }
}

class StatusLabel extends StatelessWidget {
  final AgentStatus status;

  const StatusLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, label) = switch (status) {
      AgentStatus.online => (AppColors.online, 'Connected'),
      AgentStatus.offline => (AppColors.offline, 'Offline'),
      AgentStatus.connecting => (AppColors.connecting, 'Connecting...'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusBadge(status: status),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final double size;
  final Color color;

  const _AnimatedDot({required this.size, required this.color});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.color == AppColors.connecting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(_AnimatedDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color == AppColors.connecting && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.color != AppColors.connecting && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _animation.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
