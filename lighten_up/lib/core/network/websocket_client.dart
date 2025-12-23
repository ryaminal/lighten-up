/// WebSocket Client - Real-time communication abstraction layer
///
/// This module provides WebSocket/real-time communication functionality following the Adapter Pattern.
/// Use IRealtimeClient interface for all dependencies to enable easy testing and mocking.
///
/// Example usage:
/// ```dart
/// // For dependency injection (recommended):
/// final IRealtimeClient client = WebSocketChannelAdapter();
/// ```

library;

export 'realtime_client_interface.dart';
export 'web_socket_channel_adapter.dart';
