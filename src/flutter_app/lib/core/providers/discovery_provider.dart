import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multicast_dns/multicast_dns.dart';

class RelayDiscoveryState {
  final bool searching;
  final InternetAddress? address;
  final int? port;
  final String? error;

  const RelayDiscoveryState({
    this.searching = false,
    this.address,
    this.port,
    this.error,
  });

  RelayDiscoveryState copyWith({
    bool? searching,
    InternetAddress? address,
    int? port,
    String? error,
    bool clearAddress = false,
  }) {
    return RelayDiscoveryState(
      searching: searching ?? this.searching,
      address: clearAddress ? null : address ?? this.address,
      port: clearAddress ? null : port ?? this.port,
      error: error ?? this.error,
    );
  }

  String? get url {
    if (address == null || port == null) return null;
    return 'ws://${address!.host}:$port';
  }
}

class RelayDiscoveryNotifier extends StateNotifier<RelayDiscoveryState> {
  MDnsClient? _client;

  RelayDiscoveryNotifier() : super(const RelayDiscoveryState());

  Future<void> startDiscovery() async {
    if (state.searching) return;
    state = state.copyWith(searching: true, clearAddress: true, error: null);

    try {
      _client = MDnsClient();
      await _client!.start();


      await for (final ptr
          in _client!
              .lookup<PtrResourceRecord>(
                ResourceRecordQuery.serverPointer('_acp-relay._tcp.local'),
              )
              .timeout(const Duration(seconds: 5))) {

        await for (final srv
            in _client!.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName),
            )) {

          await for (final ip
              in _client!.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target),
              )) {

            state = RelayDiscoveryState(
              searching: false,
              address: ip.address,
              port: srv.port,
            );
            _client?.stop();

            return;
          }
        }
      }


      state = state.copyWith(
        searching: false,
        error: 'No relay found on network',
      );
    } catch (e) {
      debugPrint('[ACP-DISC] Discovery error: $e');
      state = state.copyWith(
        searching: false,
        error: 'Discovery failed: $e',
      );
    } finally {
      _client?.stop();
    }
  }

  @override
  void dispose() {
    _client?.stop();
    super.dispose();
  }
}

final relayDiscoveryProvider =
    StateNotifierProvider<RelayDiscoveryNotifier, RelayDiscoveryState>((ref) {
  return RelayDiscoveryNotifier();
});
