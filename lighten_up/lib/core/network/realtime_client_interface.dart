/// Real-time Client Interface - Abstraction for WebSocket/real-time communication
///
/// This interface defines the contract for real-time bidirectional communication.
/// Follows Dependency Inversion Principle - depend on this interface, not concrete implementations.
///
/// Use this interface for all dependencies to enable easy testing, mocking, and swapping of WebSocket libraries.

library;

/// WebSocket connection state
enum WebSocketState { connecting, connected, disconnected, error }

/// Real-time client interface for bidirectional communication
abstract class IRealtimeClient {
  /// Stream of connection state changes
  Stream<WebSocketState> get stateStream;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messageStream;

  /// Current connection state
  WebSocketState get state;

  /// Check if connected
  bool get isConnected;

  /// Set the access token for authentication
  void setAccessToken(String? token);

  /// Connect to the server
  Future<void> connect(String url, {Map<String, String>? headers});

  /// Disconnect from the server
  Future<void> disconnect();

  /// Send a message
  void send(Map<String, dynamic> message);

  /// Send a typed message (for common message patterns)
  void sendTypedMessage(String type, Map<String, dynamic> data);

  /// Clean up resources
  void dispose();
}
