import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../../data/sync/sync_queue.dart';
import 'connectivity_service.dart';

/// Result of a sync operation.
class SyncResult {
  final bool success;
  final String message;
  final int itemsSynced;

  SyncResult({
    required this.success,
    required this.message,
    this.itemsSynced = 0,
  });
}

/// Service for syncing local data with Supabase.
///
/// Implements a local-first sync strategy:
/// 1. Write to local SQLite immediately
/// 2. Queue sync operation
/// 3. Process queue when online
class SyncService {
  final SupabaseClient _supabase;
  final AppDatabase _localDb;
  final ConnectivityService _connectivity;
  final LocalSyncQueue _syncQueue;

  final _uuid = const Uuid();

  final StreamController<SyncResult> _syncCompletedController =
      StreamController<SyncResult>.broadcast();

  /// Stream that emits when sync completes (for UI refresh).
  Stream<SyncResult> get onSyncCompleted => _syncCompletedController.stream;

  bool _isSyncing = false;
  DateTime? _lastSyncAt;

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<AuthState>? _authSubscription;

  SyncService(this._supabase, this._localDb, this._connectivity)
      : _syncQueue = LocalSyncQueue();

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Whether a sync is currently in progress.
  bool get isSyncing => _isSyncing;

  /// When the last successful sync occurred.
  DateTime? get lastSyncAt => _lastSyncAt;

  /// Initialize the sync service.
  Future<void> initialize() async {
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (isOnline) {
        if (isOnline) {
          debugPrint('SyncService: Back online, triggering sync');
          syncAll();
        }
      },
    );

    // Listen for auth state changes (login triggers sync)
    _authSubscription = _supabase.auth.onAuthStateChange.listen(
      (authState) {
        if (authState.event == AuthChangeEvent.signedIn ||
            authState.event == AuthChangeEvent.userUpdated ||
            authState.event == AuthChangeEvent.initialSession) {
          debugPrint('SyncService: Auth state changed (${authState.event}), triggering sync');
          // Reset last sync time to pull all data for the new user
          _lastSyncAt = null;
          syncAll();
        }
      },
    );

    // Initial sync if online and authenticated
    if (_connectivity.isOnline && _userId != null) {
      await syncAll();
    }
  }

  /// Perform a full sync.
  ///
  /// 1. Process offline queue
  /// 2. Pull changes from server
  /// 3. Push local changes
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    if (_userId == null) {
      return SyncResult(success: false, message: 'Not authenticated');
    }

    if (!_connectivity.isOnline) {
      return SyncResult(success: false, message: 'No internet connection');
    }

    _isSyncing = true;
    int itemsSynced = 0;

    try {
      debugPrint('SyncService: Starting full sync...');

      // 1. Process offline queue first
      final queueResult = await _processOfflineQueue();
      itemsSynced += queueResult;

      // 2. Pull changes from server
      await _pullChanges();

      // 3. Push local changes
      final pushResult = await _pushLocalChanges();
      itemsSynced += pushResult;

      _lastSyncAt = DateTime.now();
      debugPrint('SyncService: Sync completed. $itemsSynced items synced.');

      final result = SyncResult(
        success: true,
        message: 'Sync completed',
        itemsSynced: itemsSynced,
      );

      // Notify listeners that sync completed (for UI refresh)
      _syncCompletedController.add(result);

      return result;
    } catch (e) {
      debugPrint('SyncService: Sync error: $e');
      return SyncResult(success: false, message: e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Queue a habit operation for sync.
  Future<void> queueHabitSync(
    String habitId,
    SyncOperation operation, {
    Map<String, dynamic>? data,
  }) async {
    final item = SyncQueueItem(
      id: _uuid.v4(),
      tableName: 'habits',
      recordId: habitId,
      operation: operation,
      payload: data,
      createdAt: DateTime.now(),
    );

    await _syncQueue.addToQueue(item);

    // Attempt immediate sync if online
    if (_connectivity.isOnline && _userId != null) {
      _processSingleItem(item);
    }
  }

  /// Queue a completion operation for sync.
  Future<void> queueCompletionSync(
    String completionId,
    SyncOperation operation, {
    Map<String, dynamic>? data,
  }) async {
    final item = SyncQueueItem(
      id: _uuid.v4(),
      tableName: 'habit_completions',
      recordId: completionId,
      operation: operation,
      payload: data,
      createdAt: DateTime.now(),
    );

    await _syncQueue.addToQueue(item);

    if (_connectivity.isOnline && _userId != null) {
      _processSingleItem(item);
    }
  }

  /// Process all items in the offline queue.
  Future<int> _processOfflineQueue() async {
    final queue = await _syncQueue.getQueue();
    int processed = 0;

    for (final item in queue) {
      if (item.retries >= 3) {
        debugPrint('SyncService: Skipping ${item.id} - too many retries');
        continue;
      }

      try {
        await _processSingleItem(item);
        await _syncQueue.removeFromQueue(item.id);
        processed++;
      } catch (e) {
        await _syncQueue.updateRetry(item.id, e.toString());
      }
    }

    return processed;
  }

  /// Process a single sync queue item.
  Future<void> _processSingleItem(SyncQueueItem item) async {
    if (_userId == null) return;

    switch (item.operation) {
      case SyncOperation.insert:
      case SyncOperation.update:
        await _supabase.from(item.tableName).upsert({
          ...?item.payload,
          'user_id': _userId,
        });
        break;
      case SyncOperation.delete:
        // Soft delete - set deleted_at
        await _supabase.from(item.tableName).update({
          'deleted_at': DateTime.now().toIso8601String(),
        }).eq('id', item.recordId);
        break;
    }
  }

  /// Pull changes from server since last sync.
  Future<void> _pullChanges() async {
    if (_userId == null) return;

    // Pull habits
    var habitsQuery = _supabase
        .from('habits')
        .select()
        .eq('user_id', _userId!);

    if (_lastSyncAt != null) {
      habitsQuery = habitsQuery.gt('updated_at', _lastSyncAt!.toIso8601String());
    }

    try {
      final habitsResponse = await habitsQuery;

      for (final serverHabit in habitsResponse) {
        await _mergeHabit(serverHabit);
      }

      // Pull completions
      var completionsQuery = _supabase
          .from('habit_completions')
          .select()
          .eq('user_id', _userId!);

      if (_lastSyncAt != null) {
        completionsQuery =
            completionsQuery.gt('created_at', _lastSyncAt!.toIso8601String());
      }

      final completionsResponse = await completionsQuery;

      for (final serverCompletion in completionsResponse) {
        await _mergeCompletion(serverCompletion);
      }
    } catch (e) {
      debugPrint('SyncService: Error pulling changes: $e');
      // Continue with sync even if pull fails
    }
  }

  /// Merge a server habit with local data.
  Future<void> _mergeHabit(Map<String, dynamic> serverHabit) async {
    final localHabit = await _localDb.habitDao.getById(serverHabit['id']);

    if (serverHabit['deleted_at'] != null) {
      // Server deleted - remove locally if exists
      if (localHabit != null) {
        await _localDb.habitDao.deleteHabit(serverHabit['id']);
      }
      return;
    }

    if (localHabit == null) {
      // New from server - insert locally
      await _insertLocalHabitFromServer(serverHabit);
    } else {
      // Conflict resolution: Server wins
      await _updateLocalHabitFromServer(serverHabit);
    }
  }

  /// Merge a server completion with local data.
  Future<void> _mergeCompletion(Map<String, dynamic> serverCompletion) async {
    if (serverCompletion['deleted_at'] != null) {
      // Server deleted
      await _localDb.completionDao.deleteCompletion(serverCompletion['id']);
      return;
    }

    // Check if we have this completion locally
    final localCompletions = await _localDb.completionDao.getForHabit(
      serverCompletion['habit_id'],
    );

    final exists = localCompletions.any((c) => c.id == serverCompletion['id']);

    if (!exists) {
      await _insertLocalCompletionFromServer(serverCompletion);
    }
  }

  /// Push local changes to server.
  Future<int> _pushLocalChanges() async {
    if (_userId == null) return 0;
    int pushed = 0;

    try {
      // Get all local habits
      final localHabits = await _localDb.habitDao.getAllActive();
      final archivedHabits = await _localDb.habitDao.getAllArchived();

      for (final habit in [...localHabits, ...archivedHabits]) {
        await _pushHabit(habit);
        pushed++;
      }

      // Push completions for each habit
      for (final habit in localHabits) {
        final completions =
            await _localDb.completionDao.getForHabit(habit.id);
        for (final completion in completions) {
          await _pushCompletion(completion);
          pushed++;
        }
      }
    } catch (e) {
      debugPrint('SyncService: Error pushing changes: $e');
    }

    return pushed;
  }

  Future<void> _pushHabit(Habit habit) async {
    await _supabase.from('habits').upsert({
      'id': habit.id,
      'user_id': _userId,
      'name': habit.name,
      'type': habit.type,
      'location': habit.location,
      'scheduled_time': habit.scheduledTime,
      'score': habit.score,
      'maturity': habit.maturity,
      'quick_why': habit.quickWhy,
      'feeling_why': habit.feelingWhy,
      'identity_why': habit.identityWhy,
      'outcome_why': habit.outcomeWhy,
      'count_target': habit.countTarget,
      'weekly_target': habit.weeklyTarget,
      'after_habit_id': habit.afterHabitId,
      'created_at': habit.createdAt.toIso8601String(),
      'is_archived': habit.isArchived,
      'last_decay_at': habit.lastDecayAt?.toIso8601String(),
      'timer_duration': habit.timerDuration,
      'icon': habit.icon,
    });
  }

  Future<void> _pushCompletion(HabitCompletion completion) async {
    await _supabase.from('habit_completions').upsert({
      'id': completion.id,
      'user_id': _userId,
      'habit_id': completion.habitId,
      'completed_at': completion.completedAt.toIso8601String(),
      'effective_date': completion.effectiveDate.toIso8601String(),
      'source': completion.source,
      'score_at_completion': completion.scoreAtCompletion,
      'count_achieved': completion.countAchieved,
      'credit_percentage': completion.creditPercentage,
    });
  }

  Future<void> _insertLocalHabitFromServer(Map<String, dynamic> data) async {
    await _localDb.habitDao.insertHabit(
      HabitsCompanion.insert(
        id: data['id'],
        name: data['name'],
        type: Value(data['type'] ?? 'binary'),
        scheduledTime: data['scheduled_time'],
        location: Value(data['location']),
        score: Value(data['score'] ?? 0.0),
        maturity: Value(data['maturity'] ?? 0),
        quickWhy: Value(data['quick_why']),
        feelingWhy: Value(data['feeling_why']),
        identityWhy: Value(data['identity_why']),
        outcomeWhy: Value(data['outcome_why']),
        countTarget: Value(data['count_target']),
        weeklyTarget: Value(data['weekly_target']),
        afterHabitId: Value(data['after_habit_id']),
        isArchived: Value(data['is_archived'] ?? false),
        timerDuration: Value(data['timer_duration']),
        icon: Value(data['icon']),
      ),
    );
  }

  Future<void> _updateLocalHabitFromServer(Map<String, dynamic> data) async {
    await _localDb.habitDao.updateFields(
      data['id'],
      HabitsCompanion(
        name: Value(data['name']),
        type: Value(data['type'] ?? 'binary'),
        scheduledTime: Value(data['scheduled_time']),
        location: Value(data['location']),
        score: Value(data['score'] ?? 0.0),
        maturity: Value(data['maturity'] ?? 0),
        quickWhy: Value(data['quick_why']),
        feelingWhy: Value(data['feeling_why']),
        identityWhy: Value(data['identity_why']),
        outcomeWhy: Value(data['outcome_why']),
        countTarget: Value(data['count_target']),
        weeklyTarget: Value(data['weekly_target']),
        afterHabitId: Value(data['after_habit_id']),
        isArchived: Value(data['is_archived'] ?? false),
        timerDuration: Value(data['timer_duration']),
        icon: Value(data['icon']),
      ),
    );
  }

  Future<void> _insertLocalCompletionFromServer(Map<String, dynamic> data) async {
    await _localDb.completionDao.insertCompletion(
      HabitCompletionsCompanion.insert(
        id: data['id'],
        habitId: data['habit_id'],
        completedAt: DateTime.parse(data['completed_at']),
        effectiveDate: DateTime.parse(data['effective_date']),
        source: Value(data['source'] ?? 'manual'),
        scoreAtCompletion: data['score_at_completion'],
        countAchieved: Value(data['count_achieved']),
        creditPercentage: Value(data['credit_percentage'] ?? 100.0),
      ),
    );
  }

  /// Migrate data from anonymous user to authenticated user.
  ///
  /// Called after a user signs in with email/Google/Apple to transfer
  /// any habits and completions created while anonymous.
  Future<int> migrateAnonymousData(String anonymousUserId) async {
    if (_userId == null) {
      debugPrint('SyncService: Cannot migrate - not authenticated');
      return 0;
    }

    if (anonymousUserId == _userId) {
      debugPrint('SyncService: Same user ID, no migration needed');
      return 0;
    }

    if (!_connectivity.isOnline) {
      debugPrint('SyncService: Cannot migrate - offline');
      return 0;
    }

    debugPrint('SyncService: Migrating data from $anonymousUserId to $_userId');
    int migratedCount = 0;

    try {
      // Migrate habits
      final habitsResult = await _supabase
          .from('habits')
          .update({'user_id': _userId})
          .eq('user_id', anonymousUserId)
          .select();

      migratedCount += (habitsResult as List).length;
      debugPrint('SyncService: Migrated ${habitsResult.length} habits');

      // Migrate completions
      final completionsResult = await _supabase
          .from('habit_completions')
          .update({'user_id': _userId})
          .eq('user_id', anonymousUserId)
          .select();

      migratedCount += (completionsResult as List).length;
      debugPrint('SyncService: Migrated ${completionsResult.length} completions');

      // After migration, sync to pull the migrated data locally
      if (migratedCount > 0) {
        await syncAll();
      }

      debugPrint('SyncService: Migration complete. $migratedCount items migrated.');
      return migratedCount;
    } catch (e) {
      debugPrint('SyncService: Migration error: $e');
      return 0;
    }
  }

  /// Dispose of resources.
  void dispose() {
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    _syncCompletedController.close();
  }
}
