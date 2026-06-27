import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/discovery_provider.dart';
import '../../../core/models/connection_state.dart';
import '../../../core/theme/app_spacing.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  ConsumerState<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> {
  final _codeController = TextEditingController();
  final _manualHostController = TextEditingController(text: '192.168.1.12');
  final _manualPortController = TextEditingController(text: '8000');
  bool _discoveryStarted = false;
  bool _isConnecting = false;
  bool _showManualEntry = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _manualHostController.dispose();
    _manualPortController.dispose();
    super.dispose();
  }

  String? get _manualRelayUrl {
    final host = _manualHostController.text.trim();
    final port = _manualPortController.text.trim();
    if (host.isEmpty || port.isEmpty) return null;
    return 'ws://$host:$port';
  }

  void _onCodeChanged() {
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
    setState(() {});
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
    final url = discovery.url ?? _manualRelayUrl;
    ref.read(connectionProvider.notifier).connect(code, relayUrl: url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discovery = ref.watch(relayDiscoveryProvider);
    final isDark = theme.brightness == Brightness.dark;

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

    final bgColors = isDark
        ? [const Color(0xFF0D0D2B), const Color(0xFF1A1A4E)]
        : [const Color(0xFF1A237E), const Color(0xFF283593)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(theme),
                  const SizedBox(height: 48),
                  _buildContent(theme, discovery, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.cast_connected,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'ACP Remote',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect to your AI agents',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, RelayDiscoveryState discovery, bool isDark) {
    if (discovery.searching) {
      return _buildSearching(isDark);
    } else if (discovery.error != null) {
      return _buildError(discovery.error!, isDark);
    } else {
      return _buildCodeInput(isDark);
    }
  }

  Widget _buildSearching(bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          _PulsingDots(),
          const SizedBox(height: 20),
          const Text(
            'Searching for relay...',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Make sure the relay is running on your network',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Column(
      children: [
        _GlassCard(
          isDark: isDark,
          child: Column(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(relayDiscoveryProvider.notifier).startDiscovery();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Retry', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _showManualEntry = true);
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Manual', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showManualEntry) ...[
          const SizedBox(height: 16),
          _buildManualEntry(isDark),
          const SizedBox(height: 16),
          _buildCodeInput(isDark),
        ],
      ],
    );
  }

  Widget _buildManualEntry(bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          const Text(
            'Enter relay address',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _manualHostController,
                  decoration: InputDecoration(
                    hintText: 'IP address',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _manualPortController,
                  decoration: InputDecoration(
                    hintText: 'Port',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInput(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi, size: 20, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              'Relay found!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _GlassCard(
          isDark: isDark,
          child: Column(
            children: [
              TextField(
                controller: _codeController,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _connect(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: 'XXX-XXX',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 28,
                    letterSpacing: 4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isConnecting ? null : _connect,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isDark ? Colors.black87 : Colors.indigo,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        )
                      : const Text(
                          'Connect',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _showHelp,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.7),
          ),
          child: const Text('How to get your code?'),
        ),
      ],
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
            Text('1. Make sure the ACP daemon is running on your PC'),
            SizedBox(height: 8),
            Text('2. Look for the pairing code in the terminal where the daemon is running'),
            SizedBox(height: 8),
            Text('3. It will look like: "847293"'),
            SizedBox(height: 8),
            Text('4. Enter that code here to connect'),
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

class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _GlassCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final phase = i / 3.0;
              final raw = (t * 3 - phase) % 1.0;
              final dotT = raw < 0 ? raw + 1 : raw;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 10 + 4 * (1 - dotT),
                height: 10 + 4 * (1 - dotT),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3 + 0.7 * (1 - dotT)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
