// ignore_for_file: unused_result
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/connectivity_service.dart';
import '../../domain/services/sync_service.dart';
import 'database_provider.dart';
import 'habit_provider.dart';
import 'supabase_provider.dart';
import 'today_habits_provider.dart';

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

  // Start listening for sync completions BEFORE initializing
  // (initialize() triggers sync which emits to the stream)
  ref.watch(syncRefreshProvider);

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

/// Listens for sync completions and refreshes habit providers.
///
/// This ensures that when sync pulls new data from the server,
/// the UI providers are refreshed to show the updated data.
final syncRefreshProvider = Provider<StreamSubscription?>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  if (syncService == null) return null;

  final subscription = syncService.onSyncCompleted.listen((result) {
    if (result.success) {
      ref.refresh(habitsStreamProvider);
      ref.refresh(todayHabitsProvider);
    }
  });

  ref.onDispose(() => subscription.cancel());

  return subscription;
});
