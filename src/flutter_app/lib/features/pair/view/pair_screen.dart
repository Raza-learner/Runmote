import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/models/connection_state.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/env.dart';
import '../../../../shared/widgets/animated_background.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  _PairScreenState createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> with WidgetsBindingObserver {
  final _codeController = TextEditingController();
  final _relayUrlController = TextEditingController();
  bool _isConnecting = false;
  bool _isAutoConnecting = true;
  bool _showCodeEntry = false;
  bool _daemonDisconnected = false;
  String? _error;
  Timer? _bgRetryTimer;

  bool _qrScanned = false;
  bool _showScanner = false;
  bool _isStartingCamera = false;
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _scannerController = MobileScannerController(autoStart: false);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoConnectWithToken());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgRetryTimer?.cancel();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _relayUrlController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Delegate to the central provider which validates the socket and
      // reconnects if needed. Avoid early return on Connected – the OS
      // may have killed the socket while backgrounded.
      if (_isAutoConnecting) return;
      debugPrint('[RUNMOTE] pairScreen resumed, delegating to provider');
      ref.read(connectionProvider.notifier).onAppResumed();
      // Also keep the local auto-connect flow for the pairing wall.
      final conn = ref.read(connectionProvider);
      if (conn.state is! Connected) {
        setState(() => _isAutoConnecting = true);
        _autoConnectWithToken();
      }
    }
  }

  Future<void> _autoConnectWithToken() async {
    String? rejectedMsg;
    String? autoToken;
    bool didSucceed = false;
    try {
      final p = await ref.read(preferencesServiceProvider.future);
      final token = p.getAuthToken();
      autoToken = token;
      final savedUrl = p.getRelayUrl();
      debugPrint('[RUNMOTE] autoConnect: token=${token != null ? "present" : "null"}, savedUrl=$savedUrl');
      if (token == null || savedUrl == null) return;

      final urlsToTry = savedUrl == defaultRelayUrl
          ? [savedUrl]
          : [savedUrl, defaultRelayUrl];

      // The relay (e.g. a free-tier Render instance) may be sleeping/waking
      // up between sessions, so a slow first connection is normal. Keep the
      // loading state and retry a few times before falling back to pairing.
      // Rejections can also be transient: after a relay restart the SQLite
      // DB is wiped, so the relay can only verify the saved token while the
      // daemon is online — give the daemon a moment to reconnect before
      // giving up on the saved connection.
      const maxAttempts = 6;
      const maxRejectedAttempts = 3;
      var rejectedCount = 0;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        for (final url in urlsToTry) {
          debugPrint('[RUNMOTE] autoConnect: trying url=$url attempt=$attempt');
          final result =
              await ref.read(connectionProvider.notifier).connectWithToken(token, url);
          if (!mounted) return;

          if (result == ConnectWithTokenResult.success) {
            debugPrint('[RUNMOTE] autoConnect: connected successfully');
            didSucceed = true;
            context.go('/agents');
            return;
          }

          if (result == ConnectWithTokenResult.rejected) {
            rejectedCount++;
            debugPrint('[RUNMOTE] autoConnect: token rejected by relay ($rejectedCount/$maxRejectedAttempts)');
            // Don't give up immediately — free-tier DB wipes make rejections
            // transient while the daemon reconnects. Treat like unreachable and
            // keep the loader visible; background retry will heal.
            continue;
          }
          // unreachable — try the next URL, then retry after a delay below.
        }

        if (attempt < maxAttempts) {
          const delay = Duration(seconds: 10);
          debugPrint('[RUNMOTE] autoConnect: retrying in ${delay.inSeconds}s');
          await Future.delayed(delay);
          if (!mounted) return;
        }
      }
      debugPrint('[RUNMOTE] autoConnect: retries exhausted, showing pairing screen');
      if (rejectedCount >= maxRejectedAttempts) {
        rejectedMsg = 'Your saved connection expired. Please pair your device again.';
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAutoConnecting = false;
          _error = rejectedMsg;
        });
        // Only keep retrying if we actually have a saved token and didn't
        // already succeed. After an explicit unpair the token is cleared and
        // we must show the pairing screen immediately, not the reconnecting
        // loader.
        if (!didSucceed && autoToken != null) {
          _startBackgroundRetry();
          // Also ensure the provider's reconnect loop is armed.
          ref.read(connectionProvider.notifier).retryNow();
        }
      }
    }
  }

  void _startBackgroundRetry() {
    _bgRetryTimer?.cancel();
    _bgRetryTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!mounted) return;
      final conn = ref.read(connectionProvider);
      if (conn.state is Connected) {
        _bgRetryTimer?.cancel();
        return;
      }
      final p = await ref.read(preferencesServiceProvider.future);
      final token = p.getAuthToken();
      final savedUrl = p.getRelayUrl();
      if (token == null || savedUrl == null) {
        _bgRetryTimer?.cancel();
        return;
      }
      debugPrint('[RUNMOTE] bg retry: trying $savedUrl');
      final res =
          await ref.read(connectionProvider.notifier).connectWithToken(token, savedUrl);
      if (!mounted) return;
      if (res == ConnectWithTokenResult.success) {
        debugPrint('[RUNMOTE] bg retry: connected');
        _bgRetryTimer?.cancel();
        if (mounted) context.go('/agents');
      }
    });
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
    // Guest demo mode: allow reviewer to bypass pairing wall for Play Console review
    if (pairingCode == 'DEMO-A1B2') {
      setState(() {
        _isConnecting = false;
        _showCodeEntry = false;
      });
      context.go('/agents');
      return;
    }
    setState(() {
      _isConnecting = true;
      _error = null;
    });
    final customUrl = _relayUrlController.text.trim();
    ref.read(connectionProvider.notifier).connect(pairingCode, relayUrl: relayUrl ?? (customUrl.isNotEmpty ? customUrl : null));
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
          _daemonDisconnected = false;
        });
        context.go('/agents');
      } else if (next.state is Failed) {
        _scannerController.stop();
        setState(() {
          _isConnecting = false;
          _showScanner = false;
          _error = next.error ?? AppLocalizations.of(context)!.pairConnectionFailed;
          _qrScanned = false;
        });
      } else if ((prev?.daemonConnected ?? false) && !next.daemonConnected && !next.paired) {
        setState(() {
          _daemonDisconnected = true;
          _isConnecting = false;
          _error = AppLocalizations.of(context)!.pairDaemonDisconnected;
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
            clipBehavior: Clip.antiAlias,
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
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Image.asset(
                  'assets/logos/app_icon_foreground.png',
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.pairTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.pairSubtitle,
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
    if (_isAutoConnecting) return _buildReconnectingLoader(theme, isDark);
    // If a background retry is still active after the initial auto-connect
    // failed, keep showing the reconnecting loader instead of flashing the
    // pairing options. This prevents the "pairing for a few seconds then
    // auto-connect" flicker on cold starts where the relay is waking up.
    if (_bgRetryTimer?.isActive ?? false) {
      return _buildReconnectingLoader(theme, isDark, isBackgroundRetry: true);
    }
    if (_daemonDisconnected) return _buildDaemonDisconnected(theme, isDark);
    if (_showScanner) return _buildQrScanner(isDark);
    if (_showCodeEntry) return _buildCodeInput(isDark);
    return _buildOptions(theme, isDark);
  }

  Widget _buildReconnectingLoader(ThemeData theme, bool isDark, {bool isBackgroundRetry = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isBackgroundRetry ? 'Restoring your session…' : AppLocalizations.of(context)!.pairConnecting,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isBackgroundRetry
              ? 'Securely reconnecting to your relay'
              : 'This may take a moment if the relay is waking up',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF64748B),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        if (isBackgroundRetry) ...[
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              _bgRetryTimer?.cancel();
              setState(() {});
            },
            child: Text(
              'Show pairing options',
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6366F1),
                fontSize: 13,
              ),
            ),
          ),
        ],
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
        if (!_showCodeEntry && !_showScanner && !(_bgRetryTimer?.isActive ?? false) && !_daemonDisconnected) ...[
          _OptionCard(
            icon: Icons.qr_code_scanner_rounded,
            title: AppLocalizations.of(context)!.pairScanQrTitle,
            subtitle: AppLocalizations.of(context)!.pairScanQrSubtitle,
            isDark: isDark,
            gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
            onTap: () async {
              try {
                final status = await Permission.camera.request();
                if (!mounted) return;
                if (status.isGranted || status.isLimited) {
                  setState(() {
                    _showScanner = true;
                    _isStartingCamera = true;
                    _error = null;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    try {
                      await _scannerController.start();
                      if (mounted) {
                        setState(() => _isStartingCamera = false);
                      }
                    } catch (e) {
                      debugPrint('[QR] start error: $e');
                      if (mounted) {
                        setState(() {
                          _error = 'Camera error: $e';
                          _isStartingCamera = false;
                        });
                      }
                    }
                  });
                } else if (status.isPermanentlyDenied) {
                  setState(() => _error = 'Camera permission permanently denied. Open app settings to enable.');
                  await openAppSettings();
                } else {
                  setState(() => _error = 'Camera permission is required to scan QR codes.');
                }
              } catch (e) {
                debugPrint('[QR] onTap error: $e');
                if (mounted) setState(() => _error = 'Camera error: $e');
              }
            },
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _codeController.text = 'DEMO-A1B2';
              setState(() => _showCodeEntry = true);
            },
            icon: Icon(Icons.person_outlined, size: 16,
              color: isDark ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF94A3B8)),
            label: Text(
              AppLocalizations.of(context)!.pairGuestModeTitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF94A3B8),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _OptionCard(
          icon: Icons.qr_code_scanner_rounded,
          title: AppLocalizations.of(context)!.pairScanQrTitle,
          subtitle: AppLocalizations.of(context)!.pairScanQrSubtitle,
          isDark: isDark,
          gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
          onTap: () async {
            try {
              final status = await Permission.camera.request();
              if (!mounted) return;
              if (status.isGranted || status.isLimited) {
                setState(() {
                  _showScanner = true;
                  _isStartingCamera = true;
                  _error = null;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  try {
                    await _scannerController.start();
                    if (mounted) {
                      setState(() => _isStartingCamera = false);
                    }
                  } catch (e) {
                    debugPrint('[QR] start error: $e');
                    if (mounted) {
                      setState(() {
                        _error = 'Camera error: $e';
                        _isStartingCamera = false;
                      });
                    }
                  }
                });
              } else if (status.isPermanentlyDenied) {
                setState(() => _error = 'Camera permission permanently denied. Open app settings to enable.');
                await openAppSettings();
              } else {
                setState(() => _error = 'Camera permission is required to scan QR codes.');
              }
            } catch (e) {
              debugPrint('[QR] scanner onTap error: $e');
              if (mounted) setState(() => _error = 'Camera error: $e');
            }
          },
        ),
        const SizedBox(height: 16),
        _OptionCard(
          icon: Icons.keyboard_rounded,
          title: AppLocalizations.of(context)!.pairManualCodeTitle,
          subtitle: AppLocalizations.of(context)!.pairManualCodeSubtitle,
          isDark: isDark,
          gradient: const [Color(0xFF94A3B8), Color(0xFF64748B)],
          onTap: () => setState(() {
            _showCodeEntry = true;
            _error = null;
          }),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _showHelp,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.white.withOpacity(0.5) : theme.colorScheme.primary.withOpacity(0.7),
          ),
          child: Text(AppLocalizations.of(context)!.pairNeedHelp),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _showRelaySettings,
          icon: Icon(
            Icons.settings_outlined,
            size: 16,
            color: isDark ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF94A3B8),
          ),
          label: Text(
            'Relay Settings',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF94A3B8),
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDaemonDisconnected(ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0x33FF5252),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.cloud_off_rounded, size: 44, color: Color(0xFFFF8A80)),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.pairConnectionLostTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The remote device disconnected.\nMake sure the daemon is running on your PC.\n\nRun this command in your terminal:\nrunmote',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 220,
          height: 48,
          child: FilledButton(
            onPressed: () {
              setState(() {
                _daemonDisconnected = false;
                _showScanner = false;
                _showCodeEntry = false;
                _error = null;
                _isConnecting = false;
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? Colors.white : theme.colorScheme.primary,
              foregroundColor: isDark ? Colors.black87 : Colors.white,
            ),
            child: const Text(
              'Back to Pairing Options',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
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
                    _isStartingCamera = false;
                    _error = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.pairScanQrTitle,
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
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
                  if (!_isStartingCamera) const _QrViewfinder(),
                  if (_isStartingCamera)
                    Container(
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Starting camera...',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
                    AppLocalizations.of(context)!.pairCodeEntryHeader,
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
                  hintText: AppLocalizations.of(context)!.pairCodeHint,
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
                      : Text(
                          AppLocalizations.of(context)!.pairConnect,
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

  void _showRelaySettings() {
    final tempController = TextEditingController(text: _relayUrlController.text);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Relay Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Leave empty to use the cloud relay.\nEnter a URL for a local relay.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tempController,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ws://192.168.1.x:8000',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFCBD5E1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFF6366F1).withOpacity(0.5),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withOpacity(0.03),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _relayUrlController.text = tempController.text.trim();
                        });
                        Navigator.of(ctx).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelp() {
    final l = AppLocalizations.of(context);
    final steps = [
      (Icons.download_rounded, l!.pairHelpStep1, 'Install daemon with one curl command'),
      (Icons.qr_code_rounded, l.pairHelpStep2, 'Get 8-char code from terminal'),
      (Icons.phone_android_rounded, l.pairHelpStep3, 'Pair phone & start coding anywhere'),
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(l.pairHelpDialogTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              for (int i = 0; i < steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                        child: Icon(steps[i].$1, size: 22, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Step ${i + 1}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(steps[i].$2, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                        Text(steps[i].$3, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ])),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.pairHelpGotIt))),
            ],
          ),
        );
      },
    );
  }
}

class _QrViewfinder extends StatefulWidget {
  const _QrViewfinder();
  @override
  State<_QrViewfinder> createState() => _QrViewfinderState();
}

class _QrViewfinderState extends State<_QrViewfinder> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _pos;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pos = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1)),
            ),
            ..._corners(),
            AnimatedBuilder(
              animation: _pos,
              builder: (_, __) => Positioned(
                top: 12 + _pos.value * (220 - 24 - 2),
                left: 12,
                right: 12,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFF6366F1).withValues(alpha: 0.9), Colors.transparent]),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.6), blurRadius: 8)],
                  ),
                ),
              ),
            ),
            Center(child: Text('Align QR code', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.3))),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    const len = 22.0;
    const thick = 3.0;
    const radius = 16.0;
    Widget corner({required Alignment alignment, required BorderRadius borderRadius}) {
      return Align(
        alignment: alignment,
        child: Container(
          width: len,
          height: len,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: alignment.y == -1 ? thick : 0),
              left: BorderSide(color: Colors.white, width: alignment.x == -1 ? thick : 0),
              right: BorderSide(color: Colors.white, width: alignment.x == 1 ? thick : 0),
              bottom: BorderSide(color: Colors.white, width: alignment.y == 1 ? thick : 0),
            ),
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    return [
      corner(alignment: Alignment.topLeft, borderRadius: const BorderRadius.only(topLeft: Radius.circular(radius))),
      corner(alignment: Alignment.topRight, borderRadius: const BorderRadius.only(topRight: Radius.circular(radius))),
      corner(alignment: Alignment.bottomLeft, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(radius))),
      corner(alignment: Alignment.bottomRight, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(radius))),
    ];
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
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
