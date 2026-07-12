import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/models/connection_state.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_background.dart';

const _defaultRelayUrl = 'wss://runmote-relay.onrender.com';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  _PairScreenState createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> {
  final _codeController = TextEditingController();
  final _manualHostController = TextEditingController(text: '192.168.1.12');
  final _manualPortController = TextEditingController(text: '8000');
  bool _isConnecting = false;
  bool _isAutoConnecting = true;
  bool _showCodeEntry = false;
  String? _error;

  bool _qrScanned = false;
  bool _showScanner = false;
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _scannerController = MobileScannerController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoConnectWithToken());
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _manualHostController.dispose();
    _manualPortController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _autoConnectWithToken() async {
    try {
      final p = await ref.read(preferencesServiceProvider.future);
      final token = p.getAuthToken();
      final savedUrl = p.getRelayUrl();
      debugPrint('[RUNMOTE] autoConnect: token=${token != null ? "present" : "null"}, savedUrl=$savedUrl');
      if (token == null || savedUrl == null) return;

      final urlsToTry = savedUrl == _defaultRelayUrl
          ? [savedUrl]
          : [savedUrl, _defaultRelayUrl];

      for (final url in urlsToTry) {
        for (var attempt = 0; attempt < 2; attempt++) {
          if (attempt > 0) await Future.delayed(const Duration(seconds: 3));
          debugPrint('[RUNMOTE] autoConnect: trying url=$url attempt=${attempt + 1}');
          final ok = await ref.read(connectionProvider.notifier).connectWithToken(token, url);
          debugPrint('[RUNMOTE] autoConnect: url=$url attempt=${attempt + 1} result=$ok');
          if (ok && mounted) {
            context.go('/agents');
            return;
          }
        }
      }
      debugPrint('[RUNMOTE] autoConnect: all attempts failed, showing pairing screen');
    } finally {
      if (mounted) setState(() => _isAutoConnecting = false);
    }
  }

  void _onCodeChanged() {
    final text = _codeController.text;
    final chars = text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (chars.length > 8) return;
    String formatted;
    if (chars.length <= 4 && chars.length > 0) {
      formatted = chars;
    } else {
      if (chars.length >= 5 && chars.length <= 6 && RegExp(r'^\d+$').hasMatch(chars)) {
        formatted = '${chars.substring(0, 3)}-${chars.substring(3)}';
      } else {
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

  Future<void> _connect({String? code, String? relayUrl}) async {
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
    ref.read(connectionProvider.notifier).connect(pairingCode, relayUrl: relayUrl ?? _defaultRelayUrl);
  }

  bool _isValidCode(String raw) {
    return RegExp(r'^[A-Za-z0-9]{8}$').hasMatch(raw) ||
           RegExp(r'^\d{6}$').hasMatch(raw);
  }

  void _handleScannedCode(String raw) {
    raw = raw.trim();
    debugPrint('[QR] scanned raw: "$raw" (len=${raw.length})');
    if (raw.isEmpty) return;

    String code;
    String? relayUrl;
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.queryParameters.containsKey('code')) {
      code = uri.queryParameters['code']!;
      relayUrl = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
    } else {
      code = raw;
    }

    if (_isValidCode(code)) {
      _connect(code: code, relayUrl: relayUrl);
    } else {
      setState(() => _error = 'Invalid code scanned: $code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen<AcpConnection>(connectionProvider, (prev, next) {
      if (next.paired && next.state is Connected) {
        _scannerController.stop();
        setState(() {
          _isConnecting = false;
          _showScanner = false;
          _showCodeEntry = false;
        });
        context.go('/agents');
      } else if (next.state is Failed) {
        _scannerController.stop();
        setState(() {
          _isConnecting = false;
          _showScanner = false;
          _error = next.error ?? 'Connection failed';
          _qrScanned = false;
        });
      }
    });

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(theme),
                  const SizedBox(height: 56),
                  _buildContent(theme, isDark),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildContent(ThemeData theme, bool isDark) {
    if (_isAutoConnecting) return _buildLoading(isDark);
    if (_showScanner) return _buildQrScanner(isDark);
    if (_showCodeEntry) return _buildCodeInput(isDark);
    return _buildOptions(theme, isDark);
  }

  Widget _buildLoading(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connecting...',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(ThemeData theme, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 8),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x33FF5252),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFFF8A80), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFFFCDD2), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        _OptionCard(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Scan QR Code',
          subtitle: 'Use your camera to quickly link your device',
          isDark: isDark,
          gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
          onTap: () async {
            final status = await Permission.camera.request();
            if (!mounted) return;
            if (status.isGranted || status.isLimited) {
              setState(() {
                _showScanner = true;
                _error = null;
              });
            } else if (status.isPermanentlyDenied) {
              setState(() => _error = 'Camera permission permanently denied. Open app settings to enable.');
              await openAppSettings();
            } else {
              setState(() => _error = 'Camera permission is required to scan QR codes.');
            }
          },
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

  Widget _buildQrScanner(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurface),
                onPressed: () {
                  _scannerController.stop();
                  setState(() {
                    _showScanner = false;
                    _error = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Scan QR Code',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                  if (_qrScanned || _isConnecting) return;
                  final barcode = capture.barcodes.firstOrNull;
                  final raw = barcode?.rawValue?.trim();
                  if (raw != null && raw.isNotEmpty) {
                    _qrScanned = true;
                    _scannerController.stop();
                    _handleScannedCode(raw);
                  }
                },
                errorBuilder: (context, error) {
                  debugPrint('[QR] scanner error: $error');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Camera error: ${error.errorCode.name}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 13)),
          ),
      ],
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
                    icon: Icon(Icons.arrow_back,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurface),
                    onPressed: () => setState(() {
                      _showCodeEntry = false;
                      _error = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Enter Code',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
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
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : theme.colorScheme.onSurface.withOpacity(0.2),
                    fontSize: 28,
                    letterSpacing: 4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withOpacity(0.03),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 13)),
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
                    disabledBackgroundColor: (isDark ? Colors.white : theme.colorScheme.primary)
                        .withValues(alpha: 0.2),
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
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: onTap,
            child: Padding(
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
                          color: gradient.first.withValues(alpha: 0.3),
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
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
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
          padding: EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
