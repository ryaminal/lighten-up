import 'dart:async';

import 'package:lighten_up/core/network/realtime_client_interface.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Mock Realtime Client implementing IRealtimeClient interface
/// Used for testing without requiring actual WebSocket connections
/// Simulates real-time events and state changes
class MockRealtimeClient implements IRealtimeClient {
  WebSocketState _state = WebSocketState.disconnected;
  // Token stored for potential future authentication features
  // ignore: unused_field
  String? _accessToken;

  final _stateController = StreamController<WebSocketState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  // Simulated heartbeat timer
  Timer? _heartbeatTimer;

  @override
  Stream<WebSocketState> get stateStream => _stateController.stream;

  @override
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  @override
  WebSocketState get state => _state;

  @override
  bool get isConnected => _state == WebSocketState.connected;

  @override
  void setAccessToken(String? token) {
    _accessToken = token;
    AppLogger.debug('MockRealtimeClient: Access token set');
  }

  @override
  Future<void> connect(String url, {Map<String, String>? headers}) async {
    if (_state == WebSocketState.connected ||
        _state == WebSocketState.connecting) {
      AppLogger.warning('MockRealtimeClient: Already connected or connecting');
      return;
    }

    _updateState(WebSocketState.connecting);
    AppLogger.info('MockRealtimeClient: Connecting to $url');

    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));

    _updateState(WebSocketState.connected);
    _startHeartbeat();

    AppLogger.info('MockRealtimeClient: Connected successfully');

    // Simulate initial connection message
    _simulateIncomingMessage({
      'type': 'connected',
      'message': 'Connected to mock server',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> disconnect() async {
    AppLogger.info('MockRealtimeClient: Disconnecting');

    _stopHeartbeat();
    _updateState(WebSocketState.disconnected);

    AppLogger.info('MockRealtimeClient: Disconnected');
  }

  @override
  void send(Map<String, dynamic> message) {
    if (_state != WebSocketState.connected) {
      AppLogger.error(
        'MockRealtimeClient: Cannot send message - not connected',
      );
      return;
    }

    AppLogger.debug('MockRealtimeClient: Sending message: $message');

    // Simulate server echo/response
    Future.delayed(const Duration(milliseconds: 100), () {
      _simulateIncomingMessage({
        'type': 'echo',
        'original_message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  void sendTypedMessage(String type, Map<String, dynamic> data) {
    send({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _stopHeartbeat();
    _stateController.close();
    _messageController.close();
    AppLogger.debug('MockRealtimeClient: Disposed');
  }

  // ========== Helper Methods ==========

  void _updateState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      AppLogger.debug('MockRealtimeClient: State changed to $newState');
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_state == WebSocketState.connected) {
        _simulateIncomingMessage({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _simulateIncomingMessage(Map<String, dynamic> message) {
    if (_state == WebSocketState.connected) {
      _messageController.add(message);
      AppLogger.debug('MockRealtimeClient: Received message: $message');
    }
  }

  // ========== Test Helper Methods ==========

  /// Simulate an incoming message from the server (for testing)
  void simulateMessage(Map<String, dynamic> message) {
    _simulateIncomingMessage(message);
  }

  /// Simulate a connection error (for testing)
  void simulateError() {
    _updateState(WebSocketState.error);
    AppLogger.error('MockRealtimeClient: Simulated error');
  }

  /// Simulate server disconnect (for testing)
  void simulateDisconnect() {
    _stopHeartbeat();
    _updateState(WebSocketState.disconnected);
    AppLogger.warning('MockRealtimeClient: Simulated disconnect');
  }

  /// Simulate new notification (for testing)
  void simulateNotification(String title, String message) {
    _simulateIncomingMessage({
      'type': 'notification',
      'data': {
        'title': title,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Simulate new alert (for testing)
  void simulateAlert(String severity, String message) {
    _simulateIncomingMessage({
      'type': 'alert',
      'data': {
        'severity': severity,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Simulate user status change (for testing)
  void simulateUserStatusChange(String userId, String status) {
    _simulateIncomingMessage({
      'type': 'user_status_change',
      'data': {
        'user_id': userId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }
}
