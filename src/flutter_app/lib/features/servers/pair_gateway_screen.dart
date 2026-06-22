import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/gateway_provider.dart';
import '../../core/models/gateway_source.dart';

class PairGatewayScreen extends ConsumerStatefulWidget {
  const PairGatewayScreen({super.key});

  @override
  ConsumerState<PairGatewayScreen> createState() => _PairGatewayScreenState();
}

class _PairGatewayScreenState extends ConsumerState<PairGatewayScreen> {
  int _stepIndex = 0;
  late TextEditingController _nameController;
  late TextEditingController _hostController;
  late TextEditingController _pairingCodeController;
  late TextEditingController _deviceNameController;
  String _scheme = 'https';
  bool _isSaving = false;
  bool _codeImported = false;

  final _steps = [
    _PairingStepData(
      title: 'Run the gateway',
      body: 'Download and run the Ferngeist ACP Gateway on your desktop or server.',
      icon: Icons.computer,
    ),
    _PairingStepData(
      title: 'Import pairing code',
      body: 'Scan the QR code or paste the pairing payload from the gateway.',
      icon: Icons.qr_code_2,
    ),
    _PairingStepData(
      title: 'Review and save',
      body: 'Confirm the details and save the gateway connection.',
      icon: Icons.link,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _hostController = TextEditingController();
    _pairingCodeController = TextEditingController();
    _deviceNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _pairingCodeController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _steps[_stepIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair Gateway'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_stepIndex > 0) {
              setState(() => _stepIndex--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${_stepIndex + 1} of ${_steps.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _StepProgress(
              currentStep: _stepIndex,
              totalSteps: _steps.length,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            step.icon,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.body,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_stepIndex == 0) _buildRunStep(theme),
                        if (_stepIndex == 1) _buildImportStep(theme),
                        if (_stepIndex == 2) _buildReviewStep(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _onNext,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _stepIndex < _steps.length - 1 ? 'Next' : 'Save Gateway',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bullets([
          'Run your ACP gateway on your network or local machine',
        ], theme),
        const SizedBox(height: 12),
        Text(
          'The gateway will provide a pairing code that you can paste in the next step.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildImportStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _pairingCodeController,
          decoration: InputDecoration(
            labelText: 'Pairing payload',
            hintText: 'Paste the pairing code or QR payload here',
            border: OutlineInputBorder(),
            prefixIcon: const Icon(Icons.qr_code_2),
            suffixIcon: _pairingCodeController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _pairingCodeController.clear();
                      setState(() => _codeImported = false);
                    },
                  )
                : null,
          ),
          maxLines: 3,
          onChanged: _onPairingCodeChanged,
        ),
        if (_codeImported) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      'Payload recognized',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _pairingCodeController.text.length > 40
                      ? '${_pairingCodeController.text.substring(0, 40)}...'
                      : _pairingCodeController.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _simulateLocalPairing,
          icon: const Icon(Icons.computer),
          label: const Text('Use local gateway'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR scanning requires mobile_scanner package')),
            );
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scan QR Code'),
        ),
      ],
    );
  }

  void _onPairingCodeChanged(String value) {
    setState(() {
      _codeImported = value.trim().isNotEmpty;
    });
    if (value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          if (decoded['host'] != null) _hostController.text = decoded['host'] as String;
          if (decoded['name'] != null) _nameController.text = decoded['name'] as String;
          if (decoded['scheme'] != null) _scheme = decoded['scheme'] as String;
        }
      } catch (_) {}
    }
  }

  void _simulateLocalPairing() {
    _pairingCodeController.text = '{"host":"127.0.0.1:5788","name":"Local Gateway","scheme":"http"}';
    _onPairingCodeChanged(_pairingCodeController.text);
    _nameController.text = 'Local Gateway';
    _hostController.text = '127.0.0.1:5788';
    _scheme = 'http';
    setState(() => _codeImported = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local gateway configured')),
    );
  }

  Widget _buildReviewStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Gateway name',
            hintText: 'My Home Server',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _protocolButton('http', theme),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _protocolButton('https', theme),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _hostController,
          decoration: const InputDecoration(
            labelText: 'Host',
            hintText: '192.168.1.12:5788',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _deviceNameController,
          decoration: const InputDecoration(
            labelText: 'Device name (optional)',
            hintText: 'my-desktop-pc',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You can also manually enter the gateway URL and device name if you don\'t have a pairing code.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _protocolButton(String protocol, ThemeData theme) {
    final isSelected = _scheme == protocol;
    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => setState(() => _scheme = protocol),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (protocol == 'https')
                Icon(Icons.lock, size: 16, color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant),
              if (protocol == 'https') const SizedBox(width: 6),
              Text(
                protocol.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullets(List<String> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: TextStyle(color: theme.colorScheme.primary)),
            Expanded(child: Text(item, style: theme.textTheme.bodyLarge)),
          ],
        ),
      )).toList(),
    );
  }

  void _onNext() {
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
      if (_stepIndex == 2 && _hostController.text.isEmpty) {
        _hostController.text = '127.0.0.1:5788';
      }
      if (_stepIndex == 2 && _nameController.text.isEmpty) {
        _nameController.text = 'Gateway ${DateTime.now().hour}:${DateTime.now().minute}';
      }
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final gateway = GatewaySource(
        id: const Uuid().v4(),
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'Gateway ${DateTime.now().millisecondsSinceEpoch}',
        scheme: _scheme,
        host: _hostController.text.trim(),
        gatewayCredential: _pairingCodeController.text.trim(),
      );
      await ref.read(gatewayListProvider.notifier).addGateway(gateway);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _PairingStepData {
  final String title;
  final String body;
  final IconData icon;

  const _PairingStepData({
    required this.title,
    required this.body,
    required this.icon,
  });
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgress({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i <= currentStep
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
