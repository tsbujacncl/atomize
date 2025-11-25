import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/connectivity_service.dart';
import '../../domain/services/sync_service.dart';
import 'database_provider.dart';
import 'supabase_provider.dart';

/// Provides the ConnectivityService instance.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provides the SyncService instance (nullable if Supabase not configured).
final syncServiceProvider = Provider<SyncService?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase == null) return null;

  final db = ref.watch(databaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  final service = SyncService(supabase, db, connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Initializes connectivity monitoring.
final connectivityInitProvider = FutureProvider<void>((ref) async {
  final connectivity = ref.watch(connectivityServiceProvider);
  await connectivity.initialize();
});

/// Initializes sync service.
final syncInitProvider = FutureProvider<void>((ref) async {
  // Wait for connectivity to be initialized
  await ref.watch(connectivityInitProvider.future);

  final syncService = ref.watch(syncServiceProvider);
  if (syncService != null) {
    await syncService.initialize();
  }
});

/// Stream of connectivity status.
final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.onConnectivityChanged;
});

/// Current online status (synchronous).
final isCurrentlyOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.isOnline;
});
