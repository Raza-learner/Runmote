import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/models/connection_state.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/discovery_provider.dart';
import '../../../core/providers/database_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoConnectWithToken());
  }

  Future<void> _autoConnectWithToken() async {
    final p = await ref.read(preferencesServiceProvider.future);
    final token = p.getAuthToken();
    final relayUrl = p.getRelayUrl();
    if (token == null || relayUrl == null) return;

    for (var attempt = 0; attempt < 2; attempt++) {
      if (attempt > 0) await Future.delayed(const Duration(seconds: 3));
      final ok = await ref.read(connectionProvider.notifier).connectWithToken(token, relayUrl);
      if (ok && mounted) {
        context.go('/agents');
        return;
      }
    }
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
        ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B), const Color(0xFF312E81)]
        : [const Color(0xFFF9F7F2), const Color(0xFFF2EFE9), const Color(0xFFEBE7DF)];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: bgColors,
              ),
            ),
          ),
          if (isDark)
            Positioned(
              top: -100,
              right: -50,
              child: _BlurCircle(
                color: const Color(0xFF6366F1).withOpacity(0.15),
                size: 300,
              ),
            ),
          if (isDark)
            Positioned(
              bottom: -50,
              left: -50,
              child: _BlurCircle(
                color: const Color(0xFFA855F7).withOpacity(0.15),
                size: 250,
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(theme),
                    const SizedBox(height: 56),
                    _buildContent(theme, discovery, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Runmote',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Remote Access Redefined',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
            letterSpacing: 0.2,
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
    return _buildOptions(theme, isDark);
  }

  Widget _buildOptions(ThemeData theme, bool isDark) {
    return Column(
      children: [
        _StatusChip(
          icon: Icons.wifi_rounded,
          label: 'Relay found',
          color: const Color(0xFF22C55E),
        ),
        const SizedBox(height: 32),
        _OptionCard(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Scan QR Code',
          subtitle: 'Use your camera to quickly link your device',
          isDark: isDark,
          gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
          onTap: () => setState(() {
            _showScanner = true;
            _error = null;
          }),
        ),
        const SizedBox(height: 16),
        _OptionCard(
          icon: Icons.keyboard_rounded,
          title: 'Enter Manual Code',
          subtitle: 'Type the 8-character code from your terminal',
          isDark: isDark,
          gradient: const [Color(0xFF94A3B8), Color(0xFF64748B)],
          onTap: () => setState(() {
            _showCodeEntry = true;
            _error = null;
          }),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: _showHelp,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.white.withOpacity(0.5) : theme.colorScheme.primary.withOpacity(0.7),
          ),
          child: const Text('Need help finding your code?'),
        ),
      ],
    );
  }

  Widget _buildSearching(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _PulsingDots(),
        const SizedBox(height: 32),
        Text(
          'Scanning for Relay...',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ensure the Runmote daemon is active on your local network',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF64748B),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildError(String error, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(relayDiscoveryProvider.notifier).startDiscovery();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : theme.colorScheme.primary,
              side: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrScanner(bool isDark) {
    final theme = Theme.of(context);
    return _GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white.withValues(alpha: 0.7) : theme.colorScheme.onSurface),
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
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : theme.colorScheme.onSurface,
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
              color: isDark ? Colors.white.withValues(alpha: 0.6) : theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    return Column(
      children: [
        _GlassCard(
          isDark: isDark,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white.withValues(alpha: 0.7) : theme.colorScheme.onSurface),
                    onPressed: () => setState(() {
                      _showCodeEntry = false;
                      _error = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Enter Code',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.7) : theme.colorScheme.onSurface,
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
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'XXXX-XXXX',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.3) : theme.colorScheme.onSurface.withOpacity(0.2),
                          fontSize: 28,
                          letterSpacing: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.5) : theme.colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withOpacity(0.03),
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
                    backgroundColor: isDark ? Colors.white : theme.colorScheme.primary,
                    foregroundColor: isDark ? Colors.black87 : Colors.white,
                    disabledBackgroundColor: (isDark ? Colors.white : theme.colorScheme.primary).withValues(alpha: 0.2),
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
            Text('1. Make sure the Runmote daemon is running on your PC'),
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

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1E293B),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.5) : Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withOpacity(0.05),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
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
                  color: (isDark ? Colors.white : theme.colorScheme.primary).withValues(alpha: 0.3 + 0.7 * (1 - dotT)),
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
