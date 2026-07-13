import 'package:flutter/material.dart';

final _knownAgentIds = {
  'opencode',
  'codex',
  'claude',
  'cursor',
  'gemini',
  'copilot',
};

Color agentColor(String id) {
  switch (id.toLowerCase()) {
    case 'opencode':
      return const Color(0xFF3F51B5);
    case 'codex':
      return const Color(0xFF009688);
    case 'claude':
      return const Color(0xFFE65100);
    case 'cursor':
      return const Color(0xFF2E7D32);
    case 'gemini':
      return const Color(0xFF7B1FA2);
    case 'copilot':
      return const Color(0xFF546E7A);
    case 'kiro':
      return const Color(0xFF00BCD4);
    case 'hermes':
      return const Color(0xFFC2185B);
    default:
      return const Color(0xFF757575);
  }
}

String agentInitials(String name) {
  final id = name.toLowerCase();
  if (id == 'opencode') return 'O';
  if (id == 'codex') return 'Cx';
  if (id == 'claude' || id == 'claude code') return 'Cl';
  if (id == 'cursor' || id == 'cursor agent') return 'Cu';
  if (id == 'gemini' || id == 'gemini cli') return 'Ge';
  if (id == 'copilot' || id == 'github copilot') return 'Co';
  if (id == 'kiro' || id == 'kiro cli') return 'Ki';
  if (id == 'hermes' || id == 'hermes agent') return 'He';

  final parts = name.split(RegExp(r'[\s/]'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class AgentLogo extends StatelessWidget {
  final String id;
  final String name;
  final double size;

  const AgentLogo({
    super.key,
    required this.id,
    required this.name,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (_knownAgentIds.contains(id.toLowerCase())) {
      final radius = size * 0.25;
      final bgColor = agentColor(id);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: size,
          height: size,
          color: bgColor.withValues(alpha: isDark ? 0.35 : 0.12),
          child: Padding(
            padding: EdgeInsets.all(size * 0.12),
            child: Image.asset(
              'assets/logos/$id.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _letterAvatar(),
            ),
          ),
        ),
      );
    }

    return _letterAvatar();
  }

  Widget _letterAvatar() {
    final color = agentColor(id);
    final initials = agentInitials(name);
    final borderRadius = size * 0.25;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
