import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring network connectivity.
///
/// Used to determine when to sync with Supabase and
/// when to queue operations for later.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;

  /// Whether the device is currently online.
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes (true = online, false = offline).
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Initialize connectivity monitoring.
  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    if (wasOnline != _isOnline) {
      debugPrint('Connectivity changed: ${_isOnline ? "online" : "offline"}');
      _controller.add(_isOnline);
    }
  }

  /// Dispose of resources.
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
