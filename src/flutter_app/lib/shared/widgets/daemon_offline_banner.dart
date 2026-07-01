import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class DaemonOfflineBanner extends StatelessWidget {
  const DaemonOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.daemonOffline.withValues(alpha: 0.16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.power_off_rounded,
              size: 18,
              color: AppColors.daemonOffline,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Daemon is offline — start it on your remote device using '
                '“acp-remote”.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.daemonOffline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}