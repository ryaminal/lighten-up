import 'dart:convert';

/// Represents a message queued for later sending when connection is restored.
///
/// This model stores RPC call information that needs to be replayed when
/// the client reconnects to the server. Messages are ordered by timestamp
/// to ensure correct replay order.
class QueuedMessage {
  /// Unique identifier for this queued message
  final String id;

  /// RPC service name (e.g., "lighten.v1.LightService")
  final String service;

  /// RPC method name (e.g., "CreateLight")
  final String method;

  /// Serialized request data (JSON format)
  final String requestData;

  /// Timestamp when message was queued
  final DateTime timestamp;

  /// Number of retry attempts made
  final int retryCount;

  const QueuedMessage({
    required this.id,
    required this.service,
    required this.method,
    required this.requestData,
    required this.timestamp,
    this.retryCount = 0,
  });

  /// Creates a QueuedMessage from JSON map
  factory QueuedMessage.fromJson(Map<String, dynamic> json) {
    return QueuedMessage(
      id: json['id'] as String,
      service: json['service'] as String,
      method: json['method'] as String,
      requestData: json['requestData'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  /// Converts QueuedMessage to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'method': method,
      'requestData': requestData,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  /// Creates a copy with incremented retry count
  QueuedMessage incrementRetry() {
    return QueuedMessage(
      id: id,
      service: service,
      method: method,
      requestData: requestData,
      timestamp: timestamp,
      retryCount: retryCount + 1,
    );
  }

  /// Creates a new QueuedMessage with a generated ID
  factory QueuedMessage.create({
    required String service,
    required String method,
    required Map<String, dynamic> request,
  }) {
    return QueuedMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_${service}_$method',
      service: service,
      method: method,
      requestData: jsonEncode(request),
      timestamp: DateTime.now(),
    );
  }

  /// Deserializes the request data back to a Map
  Map<String, dynamic> getRequestMap() {
    return jsonDecode(requestData) as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'QueuedMessage(id: $id, service: $service, method: $method, '
        'timestamp: $timestamp, retryCount: $retryCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QueuedMessage &&
        other.id == id &&
        other.service == service &&
        other.method == method &&
        other.requestData == requestData &&
        other.timestamp == timestamp &&
        other.retryCount == retryCount;
  }

  @override
  int get hashCode {
    return Object.hash(id, service, method, requestData, timestamp, retryCount);
  }
}
