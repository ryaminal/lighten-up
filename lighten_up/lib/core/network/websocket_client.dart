import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/network/api_endpoints.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// WebSocket connection state
enum WebSocketState { connecting, connected, disconnected, error }

/// WebSocket client for real-time communication
class WebSocketClient {
  WebSocketChannel? _channel;
  String? _accessToken;
  WebSocketState _state = WebSocketState.disconnected;

  final _stateController = StreamController<WebSocketState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);

  /// Stream of connection state changes
  Stream<WebSocketState> get stateStream => _stateController.stream;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Current connection state
  WebSocketState get state => _state;

  /// Check if connected
  bool get isConnected => _state == WebSocketState.connected;

  /// Set the access token for authentication
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Connect to WebSocket server
  Future<void> connect(String url, {Map<String, String>? headers}) async {
    if (_state == WebSocketState.connected ||
        _state == WebSocketState.connecting) {
      AppLogger.warning('WebSocket already connected or connecting');
      return;
    }

    try {
      _updateState(WebSocketState.connecting);
      AppLogger.info('Connecting to WebSocket: $url');

      // Build URL with query parameters for auth if needed
      final uri = Uri.parse(url);
      final wsUrl = _accessToken != null && uri.queryParameters.isEmpty
          ? Uri.parse('$url?token=$_accessToken')
          : uri;

      _channel = WebSocketChannel.connect(wsUrl);

      // Listen to incoming messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _updateState(WebSocketState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();

      AppLogger.info('WebSocket connected successfully');
    } catch (e) {
      AppLogger.error('Failed to connect to WebSocket: $e');
      _updateState(WebSocketState.error);
      _scheduleReconnect(url, headers: headers);
      throw WebSocketException(message: 'Failed to connect to WebSocket: $e');
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    AppLogger.info('Disconnecting WebSocket');

    _stopHeartbeat();
    _stopReconnect();

    await _channel?.sink.close();
    _channel = null;

    _updateState(WebSocketState.disconnected);
    AppLogger.info('WebSocket disconnected');
  }

  /// Send a message through WebSocket
  void send(Map<String, dynamic> message) {
    if (_state != WebSocketState.connected) {
      AppLogger.error('Cannot send message: WebSocket not connected');
      throw WebSocketException(message: 'WebSocket is not connected');
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel?.sink.add(jsonMessage);
      AppLogger.debug('WebSocket message sent: $jsonMessage');
    } catch (e) {
      AppLogger.error('Failed to send WebSocket message: $e');
      throw WebSocketException(message: 'Failed to send message: $e');
    }
  }

  /// Send a typed message (for common message patterns)
  void sendTypedMessage(String type, Map<String, dynamic> data) {
    send({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle incoming messages
  void _onMessage(dynamic message) {
    try {
      AppLogger.debug('WebSocket message received: $message');

      if (message is String) {
        final data = jsonDecode(message) as Map<String, dynamic>;
        _messageController.add(data);

        // Handle ping/pong for heartbeat
        if (data['type'] == 'ping') {
          send({'type': 'pong'});
        }
      }
    } catch (e) {
      AppLogger.error('Error parsing WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _onError(dynamic error) {
    AppLogger.error('WebSocket error: $error');
    _updateState(WebSocketState.error);
  }

  /// Handle WebSocket connection closed
  void _onDone() {
    AppLogger.warning('WebSocket connection closed');
    _updateState(WebSocketState.disconnected);
    _stopHeartbeat();

    // Auto-reconnect if not manually disconnected
    if (_state != WebSocketState.disconnected) {
      _scheduleReconnect(ApiEndpoints.wsMessages);
    }
  }

  /// Update connection state
  void _updateState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      AppLogger.debug('WebSocket state changed to: $newState');
    }
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_state == WebSocketState.connected) {
        try {
          send({'type': 'ping', 'timestamp': DateTime.now().toIso8601String()});
        } catch (e) {
          AppLogger.error('Heartbeat failed: $e');
        }
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect(String url, {Map<String, String>? headers}) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.error('Max reconnect attempts reached');
      return;
    }

    _stopReconnect();
    _reconnectAttempts++;

    AppLogger.info(
      'Scheduling reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts',
    );

    _reconnectTimer = Timer(_reconnectDelay, () {
      connect(url, headers: headers);
    });
  }

  /// Stop reconnection timer
  void _stopReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}

/// Factory for creating WebSocket clients for different channels
class WebSocketClientFactory {
  static WebSocketClient createMessagesClient(String? token) {
    final client = WebSocketClient();
    client.setAccessToken(token);
    return client;
  }

  static WebSocketClient createNotificationsClient(String? token) {
    final client = WebSocketClient();
    client.setAccessToken(token);
    return client;
  }

  static WebSocketClient createAlertsClient(String? token) {
    final client = WebSocketClient();
    client.setAccessToken(token);
    return client;
  }

  static WebSocketClient createPresenceClient(String? token) {
    final client = WebSocketClient();
    client.setAccessToken(token);
    return client;
  }
}
