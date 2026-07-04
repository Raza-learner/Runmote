import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/models/connection_state.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/discovery_provider.dart';
import '../../../core/theme/app_spacing.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  _PairScreenState createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> {
  final _codeController = TextEditingController();
  final _manualHostController = TextEditingController(text: '192.168.1.12');
  final _manualPortController = TextEditingController(text: '8000');
  bool _discoveryStarted = false;
  bool _isConnecting = false;
  bool _showScanner = false;
  bool _showCodeEntry = false;
  String? _error;

  MobileScannerController? _scannerController;
  bool _qrScanned = false;

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
    _scannerController?.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final text = _codeController.text;
    final chars = text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (chars.length > 8) return;
    String formatted;
    if (chars.length <= 4 && chars.length > 0) {
      // 6-digit codes (old): format as XXX-XXX once we have 5+ chars
      // 8-char codes (new): format as XXXX-XXXX once we have 5+ chars
      formatted = chars;
    } else {
      if (chars.length >= 5 && chars.length <= 6 && RegExp(r'^\d+$').hasMatch(chars)) {
        // 6-digit: split 3-3
        formatted = '${chars.substring(0, 3)}-${chars.substring(3)}';
      } else {
        // 8-char: split 4-4
        formatted = '${chars.substring(0, 4)}-${chars.substring(4)}';
      }
    }
    if (formatted != text) {
      _codeController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {});
  }

  Future<void> _connect({String? code}) async {
    final pairingCode = (code ?? _codeController.text)
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    if (pairingCode.length != 8 && pairingCode.length != 6) {
      setState(() => _error = 'Please enter a 6-digit or 8-character pairing code');
      return;
    }
    setState(() {
      _isConnecting = true;
      _error = null;
    });
    final discovery = ref.read(relayDiscoveryProvider);
    final url = discovery.url;
    ref.read(connectionProvider.notifier).connect(pairingCode, relayUrl: url);
  }

  bool _isValidCode(String raw) {
    // Accept 8-char alphanumeric (new relay) or 6-digit (old relay).
    return RegExp(r'^[A-Za-z0-9]{8}$').hasMatch(raw) ||
           RegExp(r'^\d{6}$').hasMatch(raw);
  }

  void _onQrDetect(BarcodeCapture capture) {
    if (_qrScanned || _isConnecting) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue?.trim();
    debugPrint('[QR] scanned raw: "${raw ?? "null"}" (len=${raw?.length ?? 0})');
    if (raw != null && _isValidCode(raw)) {
      _qrScanned = true;
      _scannerController?.stop();
      _connect(code: raw);
    } else if (raw != null && raw.isNotEmpty) {
      final display = raw.length > 20 ? '${raw.substring(0, 20)}...' : raw;
      setState(() => _error = 'Scanned: "$display" (len=${raw.length})');
    }
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
        setState(() {
          _isConnecting = false;
          _showScanner = false;
          _showCodeEntry = false;
        });
        context.go('/agents');
      } else if (next.state is Failed) {
        setState(() {
          _isConnecting = false;
          _error = next.error ?? 'Connection failed';
          _qrScanned = false;
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
    } else if (_showScanner) {
      return _buildQrScanner(isDark);
    } else if (_showCodeEntry) {
      return _buildCodeInput(isDark);
    }
    return _buildOptions(isDark);
  }

  Widget _buildOptions(bool isDark) {
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
        _OptionCard(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Scan QR Code',
          subtitle: 'Point camera at the QR\ncode in the daemon terminal',
          isDark: isDark,
          onTap: () => setState(() {
            _showScanner = true;
            _error = null;
          }),
        ),
        const SizedBox(height: 16),
        _OptionCard(
          icon: Icons.keyboard_rounded,
          title: 'Enter Code',
          subtitle: 'Type the 6-digit pairing\ncode shown in the terminal',
          isDark: isDark,
          onTap: () => setState(() {
            _showCodeEntry = true;
            _error = null;
          }),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQrScanner(bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.7)),
                onPressed: () => setState(() {
                  _showScanner = false;
                  _scannerController?.stop();
                  _qrScanned = false;
                }),
              ),
              const SizedBox(width: 8),
              Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Point at the QR code in your daemon terminal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 260,
              height: 260,
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onQrDetect,
                overlayBuilder: (context, constraints) {
                  return _QrOverlay(constraints);
                },
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeInput(bool isDark) {
    return Column(
      children: [
        _GlassCard(
          isDark: isDark,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.7)),
                    onPressed: () => setState(() {
                      _showCodeEntry = false;
                      _error = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Enter Code',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _connect(),
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'XXXX-XXXX',
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
                  ),
                ],
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
            Text('2. Look for the QR code in the terminal where the daemon is running'),
            SizedBox(height: 8),
            Text('3. Use the QR scanner to scan it, or type the 8-character code shown below it'),
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

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        isDark: isDark,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4)),
          ],
        ),
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

class _QrOverlay extends StatelessWidget {
  final BoxConstraints constraints;

  const _QrOverlay(this.constraints);

  @override
  Widget build(BuildContext context) {
    final width = constraints.maxWidth * 0.6;
    final height = constraints.maxHeight * 0.6;
    final left = (constraints.maxWidth - width) / 2;
    final top = (constraints.maxHeight - height) / 2;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _QrOverlayPainter(
              scanRect: Rect.fromLTWH(left, top, width, height),
            ),
          ),
        ),
        _buildCorner(left - 4, top - 4, 1, 1),
        _buildCorner(constraints.maxWidth - left - width - 4, top - 4, -1, 1),
        _buildCorner(left - 4, constraints.maxHeight - top - height - 4, 1, -1),
        _buildCorner(constraints.maxWidth - left - width - 4, constraints.maxHeight - top - height - 4, -1, -1),
      ],
    );
  }

  Widget _buildCorner(double left, double top, int dirX, int dirY) {
    return Positioned(
      left: left,
      top: top,
      child: CustomPaint(
        size: const Size(24, 24),
        painter: _CornerPainter(dirX: dirX, dirY: dirY),
      ),
    );
  }
}

class _QrOverlayPainter extends CustomPainter {
  final Rect scanRect;

  _QrOverlayPainter({required this.scanRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(scanRect),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrOverlayPainter oldDelegate) => true;
}

class _CornerPainter extends CustomPainter {
  final int dirX;
  final int dirY;

  _CornerPainter({required this.dirX, required this.dirY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const len = 20.0;
    final ox = dirX > 0 ? 0.0 : size.width;
    final oy = dirY > 0 ? 0.0 : size.height;
    canvas.drawLine(Offset(ox, oy), Offset(ox + len * dirX, oy), paint);
    canvas.drawLine(Offset(ox, oy), Offset(ox, oy + len * dirY), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
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
