import 'package:flutter/material.dart';
import '../../core/services/preferences_service.dart';

class LaunchRiskConsentDialog extends StatefulWidget {
  final PreferencesService preferences;
  final VoidCallback onConsent;
  final VoidCallback onDismiss;

  const LaunchRiskConsentDialog({
    super.key,
    required this.preferences,
    required this.onConsent,
    required this.onDismiss,
  });

  @override
  State<LaunchRiskConsentDialog> createState() => _LaunchRiskConsentDialogState();
}

class _LaunchRiskConsentDialogState extends State<LaunchRiskConsentDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 24),
          const SizedBox(width: 8),
          const Text('Security Warning'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACP agents have the ability to execute code, read and write files, '
            'and access your system.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Only connect to agents you trust. By proceeding, you acknowledge '
            'the potential risks of remote code execution.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _dontShowAgain,
                onChanged: (v) => setState(() => _dontShowAgain = v ?? false),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
                  child: Text(
                    'Don\'t show this again',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_dontShowAgain) {
              widget.preferences.consentDismissed = true;
            }
            widget.onConsent();
          },
          child: const Text('I Understand, Continue'),
        ),
      ],
    );
  }
}
