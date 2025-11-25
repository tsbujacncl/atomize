import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Types of sync operations.
enum SyncOperation { insert, update, delete }

/// A queued sync operation for offline support.
class SyncQueueItem {
  final String id;
  final String tableName;
  final String recordId;
  final SyncOperation operation;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  int retries;
  String? lastError;

  SyncQueueItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    this.payload,
    required this.createdAt,
    this.retries = 0,
    this.lastError,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tableName': tableName,
        'recordId': recordId,
        'operation': operation.name,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retries': retries,
        'lastError': lastError,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'],
        tableName: json['tableName'],
        recordId: json['recordId'],
        operation: SyncOperation.values.byName(json['operation']),
        payload: json['payload'] != null
            ? Map<String, dynamic>.from(json['payload'])
            : null,
        createdAt: DateTime.parse(json['createdAt']),
        retries: json['retries'] ?? 0,
        lastError: json['lastError'],
      );
}

/// Local queue for sync operations that need to be sent to the server.
///
/// Operations are persisted to SharedPreferences and processed
/// when connectivity is restored.
class LocalSyncQueue {
  static const _queueKey = 'atomize_sync_queue';

  /// Get all queued items.
  Future<List<SyncQueueItem>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_queueKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((j) => SyncQueueItem.fromJson(j)).toList();
  }

  /// Add an item to the queue.
  ///
  /// If an item with the same table/record already exists,
  /// merges the operations intelligently.
  Future<void> addToQueue(SyncQueueItem item) async {
    final queue = await getQueue();

    // Check for existing item with same record
    final existingIndex = queue.indexWhere(
      (q) => q.tableName == item.tableName && q.recordId == item.recordId,
    );

    if (existingIndex >= 0) {
      final existing = queue[existingIndex];
      if (item.operation == SyncOperation.delete) {
        if (existing.operation == SyncOperation.insert) {
          // Never synced, just remove from queue
          queue.removeAt(existingIndex);
        } else {
          // Was already synced, replace with delete
          queue[existingIndex] = item;
        }
      } else {
        // Update the payload
        queue[existingIndex] = item;
      }
    } else {
      queue.add(item);
    }

    await _saveQueue(queue);
  }

  /// Remove an item from the queue after successful sync.
  Future<void> removeFromQueue(String itemId) async {
    final queue = await getQueue();
    queue.removeWhere((q) => q.id == itemId);
    await _saveQueue(queue);
  }

  /// Update retry count and error message for a failed item.
  Future<void> updateRetry(String itemId, String error) async {
    final queue = await getQueue();
    final index = queue.indexWhere((q) => q.id == itemId);
    if (index >= 0) {
      queue[index].retries++;
      queue[index].lastError = error;
      await _saveQueue(queue);
    }
  }

  /// Clear the entire queue.
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  /// Get the count of pending items.
  Future<int> getPendingCount() async {
    final queue = await getQueue();
    return queue.length;
  }

  Future<void> _saveQueue(List<SyncQueueItem> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(queue.map((q) => q.toJson()).toList());
    await prefs.setString(_queueKey, jsonStr);
  }
}
