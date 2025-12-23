import 'dart:convert';

import 'package:lighten_up/core/network/queued_message.dart';
import 'package:lighten_up/core/storage/database_interface.dart';

/// Offline message queue for persisting RPC calls when connection is unavailable.
///
/// This queue uses the IDatabase adapter to persist messages to storage, ensuring
/// they survive app restarts. Messages are replayed in chronological order (oldest first)
/// when the connection is restored.
class OfflineQueue {
  final IDatabase _database;
  IDatabaseBox<String>? _box;
  static const String _boxName = 'offline_queue';

  OfflineQueue({required IDatabase database}) : _database = database;

  /// Initializes the queue and opens the database box
  Future<void> init() async {
    await _database.init();
    _box = await _database.openBox<String>(_boxName);
  }

  /// Closes the queue and releases resources
  Future<void> close() async {
    await _box?.close();
  }

  /// Enqueues a message for later replay
  ///
  /// The message is persisted to storage immediately.
  Future<void> enqueue(QueuedMessage message) async {
    _ensureInitialized();
    final json = jsonEncode(message.toJson());
    await _box!.put(message.id, json);
  }

  /// Dequeues and returns the oldest message from the queue
  ///
  /// Returns null if the queue is empty.
  /// The message is removed from storage after being dequeued.
  Future<QueuedMessage?> dequeue() async {
    _ensureInitialized();

    final messages = await _getAllMessages();
    if (messages.isEmpty) return null;

    // Sort by timestamp (oldest first)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final oldest = messages.first;
    await _box!.delete(oldest.id);
    return oldest;
  }

  /// Returns the oldest message without removing it from the queue
  ///
  /// Returns null if the queue is empty.
  Future<QueuedMessage?> peek() async {
    _ensureInitialized();

    final messages = await _getAllMessages();
    if (messages.isEmpty) return null;

    // Sort by timestamp (oldest first)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return messages.first;
  }

  /// Returns all messages in the queue ordered by timestamp (oldest first)
  ///
  /// Useful for replaying all queued messages.
  Future<List<QueuedMessage>> getAll() async {
    _ensureInitialized();

    final messages = await _getAllMessages();
    // Sort by timestamp (oldest first)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  /// Removes a specific message from the queue
  Future<void> remove(String messageId) async {
    _ensureInitialized();
    await _box!.delete(messageId);
  }

  /// Clears all messages from the queue
  Future<void> clear() async {
    _ensureInitialized();
    await _box!.clear();
  }

  /// Returns the number of messages in the queue
  Future<int> length() async {
    _ensureInitialized();
    return await _box!.length();
  }

  /// Checks if the queue is empty
  Future<bool> isEmpty() async {
    return await length() == 0;
  }

  /// Checks if the queue has any messages
  Future<bool> isNotEmpty() async {
    return await length() > 0;
  }

  /// Updates a message in the queue (e.g., incrementing retry count)
  Future<void> update(QueuedMessage message) async {
    _ensureInitialized();
    final json = jsonEncode(message.toJson());
    await _box!.put(message.id, json);
  }

  /// Helper method to retrieve all messages from storage
  Future<List<QueuedMessage>> _getAllMessages() async {
    final jsonStrings = await _box!.getAll();
    return jsonStrings
        .map((jsonStr) {
          try {
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            return QueuedMessage.fromJson(json);
          } catch (e) {
            // Skip malformed messages
            return null;
          }
        })
        .where((msg) => msg != null)
        .cast<QueuedMessage>()
        .toList();
  }

  /// Ensures the queue is initialized before operations
  void _ensureInitialized() {
    if (_box == null) {
      throw StateError(
        'OfflineQueue not initialized. Call init() before using the queue.',
      );
    }
  }
}
