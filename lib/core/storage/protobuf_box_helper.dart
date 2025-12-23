import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import 'package:lighten_up/core/storage/database_interface.dart';

/// Helper for storing protobuf messages in database boxes.
///
/// Protobuf messages are stored as raw bytes (Uint8List) and
/// deserialized on retrieval using the message's fromBuffer method.
class ProtobufBoxHelper {
  /// Stores a protobuf message in a box as bytes.
  static Future<void> putMessage<T extends GeneratedMessage>(
    IDatabaseBox<Uint8List> box,
    String key,
    T message,
  ) async {
    final bytes = message.writeToBuffer();
    await box.put(key, Uint8List.fromList(bytes));
  }

  /// Retrieves and deserializes a protobuf message from a box.
  static Future<T?> getMessage<T extends GeneratedMessage>(
    IDatabaseBox<Uint8List> box,
    String key,
    T Function(List<int>) fromBuffer,
  ) async {
    final bytes = await box.get(key);
    if (bytes == null) return null;
    return fromBuffer(bytes);
  }

  /// Gets all protobuf messages from a box.
  static Future<List<T>> getAllMessages<T extends GeneratedMessage>(
    IDatabaseBox<Uint8List> box,
    T Function(List<int>) fromBuffer,
  ) async {
    final allBytes = await box.getAll();
    return allBytes.map((bytes) => fromBuffer(bytes)).toList();
  }
}
