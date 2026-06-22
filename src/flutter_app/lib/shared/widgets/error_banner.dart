import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialBanner(
      backgroundColor: theme.colorScheme.errorContainer,
      leading: Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
          ),
        if (onDismiss != null)
          TextButton(
            onPressed: onDismiss,
            child: Text('Dismiss', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
          ),
      ],
    );
  }
}
