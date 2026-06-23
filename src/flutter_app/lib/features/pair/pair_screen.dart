import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/connection_provider.dart';
import '../../core/providers/discovery_provider.dart';
import '../../core/models/connection_state.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  ConsumerState<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> {
  final _codeController = TextEditingController();
  bool _discoveryStarted = false;
  bool _isConnecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_formatCode);
  }

  @override
  void dispose() {
    _codeController.removeListener(_formatCode);
    _codeController.dispose();
    super.dispose();
  }

  void _formatCode() {
    final text = _codeController.text;
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 6) return;
    String formatted;
    if (digits.length <= 3) {
      formatted = digits;
    } else {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    if (formatted != text) {
      _codeController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _connect() async {
    final code = _codeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (code.length != 6) {
      setState(() => _error = 'Please enter a 6-digit pairing code');
      return;
    }

    setState(() {
      _isConnecting = true;
      _error = null;
    });

    final discovery = ref.read(relayDiscoveryProvider);
    ref.read(connectionProvider.notifier).connect(code, relayUrl: discovery.url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discovery = ref.watch(relayDiscoveryProvider);

    if (!_discoveryStarted && !discovery.searching) {
      _discoveryStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(relayDiscoveryProvider.notifier).startDiscovery();
      });
    }

    ref.listen<AcpConnection>(connectionProvider, (prev, next) {
      if (next.paired && next.state is Connected) {
        setState(() => _isConnecting = false);
        context.go('/agents');
      } else if (next.state is Failed) {
        setState(() {
          _isConnecting = false;
          _error = next.error ?? 'Connection failed';
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cast_connected,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'ACP Remote',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect to your AI agents',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                if (discovery.searching) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Searching for relay on your network...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else if (discovery.error != null) ...[
                  Icon(Icons.wifi_off, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 12),
                  Text(
                    discovery.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(relayDiscoveryProvider.notifier).startDiscovery();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ] else ...[
                  Icon(Icons.wifi, size: 28, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Relay found!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeController,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _connect(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. 847-293',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        fontSize: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isConnecting ? null : _connect,
                      child: _isConnecting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Connect', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _showHelp,
                    child: const Text('How to get your code?'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Get Your Code'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Make sure the ACP daemon is running on your PC',
            ),
            SizedBox(height: 8),
            Text(
              '2. Look for the pairing code in the terminal where the daemon is running',
            ),
            SizedBox(height: 8),
            Text(
              '3. It will look like: "847293"',
            ),
            SizedBox(height: 8),
            Text(
              '4. Enter that code here to connect',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
