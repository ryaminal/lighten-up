# Communication Protocol Design

**Document Date:** 2025-12-23
**Status:** Final Design

---

## Architecture Decisions (Confirmed)

✅ **Client-Server Architecture** - Manually configured server address
✅ **Same Codebase** - Flutter/Dart for both client and server
✅ **Future P2P Option** - Design with this in mind
✅ **ConnectRPC Protocol** - Using official Dart SDK
✅ **mDNS Discovery** - Auto-discover server address
✅ **SQLite for offline queue** - Persist messages during disconnection
✅ **Timestamp-based versioning** - For state synchronization
✅ **Configurable ports** - Default 8080 for HTTP, 5000 for gRPC
✅ **No TLS for MVP** - Trust local network
✅ **Auth behind interface** - No auth for MVP, but designed for future
✅ **Storage behind adapter** - Database abstraction for swappable implementations

---

## Why ConnectRPC?

After reviewing the official Dart SDK, ConnectRPC is the clear winner:

### Advantages:
- ✅ **Official Dart support** - `connectrpc` package is fully supported
- ✅ **Strong typing** - Compile-time type safety via protobuf
- ✅ **Code generation** - Auto-generated clients and servers
- ✅ **HTTP/1.1 and HTTP/2** - Works everywhere
- ✅ **Browser friendly** - Native support, no proxy needed
- ✅ **Bidirectional streaming** - Real-time updates built-in
- ✅ **Easy debugging** - Supports JSON mode for development
- ✅ **Curl testable** - Can test with standard HTTP tools
- ✅ **Small library** - <100KB, tree-shakable
- ✅ **Modern** - Active development, good docs
- ✅ **Simpler than gRPC** - Less complexity, same benefits

### Why Not WebSocket?
- No built-in schemas or type safety
- More manual work for serialization
- Would need to build own streaming abstraction
- ConnectRPC gives us all this for free

---

## Service Definition

We'll define our API using Protocol Buffers (.proto files).

### Directory Structure:
```
proto/
├── buf.yaml
├── buf.gen.yaml
└── lighten/
    └── v1/
        ├── light_service.proto
        ├── state_service.proto
        ├── models.proto
        └── common.proto
```

---

## Proto Definitions

### `proto/lighten/v1/common.proto`

```protobuf
syntax = "proto3";

package lighten.v1;

import "google/protobuf/timestamp.proto";

// Common timestamp type
message Timestamp {
  google.protobuf.Timestamp value = 1;
}

// User role enumeration
enum UserRole {
  USER_ROLE_UNSPECIFIED = 0;
  USER_ROLE_RECEPTIONIST = 1;
  USER_ROLE_DOCTOR = 2;
  USER_ROLE_NURSE = 3;
  USER_ROLE_TECHNICIAN = 4;
  USER_ROLE_ADMIN = 5;
}

// Light priority levels
enum LightPriority {
  LIGHT_PRIORITY_UNSPECIFIED = 0;
  LIGHT_PRIORITY_NORMAL = 1;
  LIGHT_PRIORITY_HIGH = 2;
  LIGHT_PRIORITY_URGENT = 3;
}

// Light state
enum LightState {
  LIGHT_STATE_UNSPECIFIED = 0;
  LIGHT_STATE_OFF = 1;
  LIGHT_STATE_ON = 2;
}

// Light color (based on age)
enum LightColor {
  LIGHT_COLOR_UNSPECIFIED = 0;
  LIGHT_COLOR_GRAY = 1;    // Off
  LIGHT_COLOR_GREEN = 2;   // Fresh (<5min)
  LIGHT_COLOR_YELLOW = 3;  // Aging (5-10min)
  LIGHT_COLOR_RED = 4;     // Overdue (>10min)
}
```

---

### `proto/lighten/v1/models.proto`

```protobuf
syntax = "proto3";

package lighten.v1;

import "lighten/v1/common.proto";
import "google/protobuf/timestamp.proto";

// User model
message User {
  string id = 1;
  string name = 2;
  UserRole role = 3;
  bool online = 4;
  google.protobuf.Timestamp created_at = 5;
}

// Light model
message Light {
  string id = 1;
  string name = 2;
  LightState state = 3;
  LightColor color = 4;
  LightPriority priority = 5;
  repeated string tags = 6;
  optional string comment = 7;
  google.protobuf.Timestamp created_at = 8;
  optional google.protobuf.Timestamp activated_at = 9;
  optional google.protobuf.Timestamp deactivated_at = 10;
  string created_by_user_id = 11;
  optional string activated_by_user_id = 12;

  // Age thresholds in seconds
  int32 yellow_threshold_seconds = 13;  // Default 300 (5min)
  int32 red_threshold_seconds = 14;     // Default 600 (10min)
}

// Activity/Event model
message Activity {
  string id = 1;
  string light_id = 2;
  string user_id = 3;
  ActivityType type = 4;
  optional string comment = 5;
  google.protobuf.Timestamp timestamp = 6;

  enum ActivityType {
    ACTIVITY_TYPE_UNSPECIFIED = 0;
    ACTIVITY_TYPE_CREATED = 1;
    ACTIVITY_TYPE_ACTIVATED = 2;
    ACTIVITY_TYPE_DEACTIVATED = 3;
    ACTIVITY_TYPE_UPDATED = 4;
    ACTIVITY_TYPE_COMMENTED = 5;
  }
}

// State snapshot
message StateSnapshot {
  google.protobuf.Timestamp timestamp = 1;
  repeated Light lights = 2;
  repeated User users = 3;
  int64 version = 4;  // Timestamp as version (unix epoch millis)
}
```

---

### `proto/lighten/v1/light_service.proto`

```protobuf
syntax = "proto3";

package lighten.v1;

import "lighten/v1/models.proto";
import "lighten/v1/common.proto";
import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

// Light management service
service LightService {
  // Activate a light
  rpc ActivateLight(ActivateLightRequest) returns (ActivateLightResponse);

  // Deactivate a light
  rpc DeactivateLight(DeactivateLightRequest) returns (DeactivateLightResponse);

  // Update light properties
  rpc UpdateLight(UpdateLightRequest) returns (UpdateLightResponse);

  // Add comment to light
  rpc AddLightComment(AddLightCommentRequest) returns (AddLightCommentResponse);

  // Stream light updates (server -> client push)
  rpc StreamLightUpdates(google.protobuf.Empty) returns (stream LightUpdate);

  // Get light history
  rpc GetLightHistory(GetLightHistoryRequest) returns (GetLightHistoryResponse);
}

// Activate light request
message ActivateLightRequest {
  string light_id = 1;
  string user_id = 2;
  optional string comment = 3;
  LightPriority priority = 4;
  repeated string tags = 5;
}

message ActivateLightResponse {
  Light light = 1;
  Activity activity = 2;
}

// Deactivate light request
message DeactivateLightRequest {
  string light_id = 1;
  string user_id = 2;
  optional string comment = 3;
}

message DeactivateLightResponse {
  Light light = 1;
  Activity activity = 2;
  int64 resolution_time_ms = 3;  // Time light was active (ms)
}

// Update light request
message UpdateLightRequest {
  string light_id = 1;
  string user_id = 2;
  optional string comment = 3;
  optional LightPriority priority = 4;
  repeated string tags = 5;
}

message UpdateLightResponse {
  Light light = 1;
  Activity activity = 2;
}

// Add comment request
message AddLightCommentRequest {
  string light_id = 1;
  string user_id = 2;
  string comment = 3;
}

message AddLightCommentResponse {
  Activity activity = 1;
}

// Light update stream message
message LightUpdate {
  UpdateType type = 1;
  Light light = 2;
  Activity activity = 3;

  enum UpdateType {
    UPDATE_TYPE_UNSPECIFIED = 0;
    UPDATE_TYPE_ACTIVATED = 1;
    UPDATE_TYPE_DEACTIVATED = 2;
    UPDATE_TYPE_UPDATED = 3;
    UPDATE_TYPE_COMMENTED = 4;
  }
}

// Get history request
message GetLightHistoryRequest {
  string light_id = 1;
  optional int32 limit = 2;  // Max activities to return
}

message GetLightHistoryResponse {
  repeated Activity activities = 1;
}
```

---

### `proto/lighten/v1/state_service.proto`

```protobuf
syntax = "proto3";

package lighten.v1;

import "lighten/v1/models.proto";
import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

// State synchronization service
service StateService {
  // Connect client and receive full state
  rpc Connect(ConnectRequest) returns (ConnectResponse);

  // Disconnect client
  rpc Disconnect(DisconnectRequest) returns (google.protobuf.Empty);

  // Request state sync
  rpc SyncState(SyncStateRequest) returns (SyncStateResponse);

  // Heartbeat to keep connection alive
  rpc Heartbeat(google.protobuf.Empty) returns (google.protobuf.Empty);

  // Stream state updates (server -> client push)
  rpc StreamStateUpdates(google.protobuf.Empty) returns (stream StateUpdate);
}

// Connect request
message ConnectRequest {
  string client_id = 1;
  string user_name = 2;
  UserRole role = 3;
  string version = 4;  // Client version
}

message ConnectResponse {
  string server_id = 1;
  string server_version = 2;
  int32 connected_clients = 3;
  StateSnapshot current_state = 4;
}

// Disconnect request
message DisconnectRequest {
  string client_id = 1;
  string reason = 2;
}

// Sync state request
message SyncStateRequest {
  string client_id = 1;
  optional int64 last_known_version = 2;  // Timestamp (unix epoch millis)
}

message SyncStateResponse {
  StateSnapshot full_state = 1;
  bool is_full_sync = 2;  // true if full state, false if delta
}

// State update stream message
message StateUpdate {
  int64 version = 1;  // Timestamp (unix epoch millis)
  repeated StateChange changes = 2;

  message StateChange {
    ChangeType type = 1;
    oneof change {
      Light light = 2;
      User user = 3;
      Activity activity = 4;
    }

    enum ChangeType {
      CHANGE_TYPE_UNSPECIFIED = 0;
      CHANGE_TYPE_LIGHT_ADDED = 1;
      CHANGE_TYPE_LIGHT_UPDATED = 2;
      CHANGE_TYPE_LIGHT_REMOVED = 3;
      CHANGE_TYPE_USER_JOINED = 4;
      CHANGE_TYPE_USER_LEFT = 5;
      CHANGE_TYPE_USER_UPDATED = 6;
      CHANGE_TYPE_ACTIVITY_ADDED = 7;
    }
  }
}
```

---

## Buf Configuration

### `proto/buf.yaml`

```yaml
version: v2
modules:
  - path: .
lint:
  use:
    - DEFAULT
breaking:
  use:
    - FILE
```

### `proto/buf.gen.yaml`

```yaml
version: v2
managed:
  enabled: true
plugins:
  # Generate Dart protobuf classes
  - remote: buf.build/protocolbuffers/dart
    out: ../lib/gen
    opt:
      - generate_kythe_info
    include_wkt: true
    include_imports: true

  # Generate ConnectRPC Dart clients
  - remote: buf.build/connectrpc/dart
    out: ../lib/gen
```

---

## Implementation Architecture

### Server Side (Dart)

```dart
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:lighten/gen/lighten/v1/light_service.connect.server.dart';
import 'package:lighten/gen/lighten/v1/state_service.connect.server.dart';

class LightenServer {
  late final _lightService = LightServiceImpl();
  late final _stateService = StateServiceImpl();

  Future<void> start({int port = 8080}) async {
    final router = Router()
      ..mount(_lightService)
      ..mount(_stateService);

    final handler = createConnectHandler(
      router: router,
      codec: const ProtoCodec(), // or JsonCodec() for debugging
    );

    await io.serve(handler, 'localhost', port);
    print('Server started on port $port');
  }
}

// Implement the light service
class LightServiceImpl extends LightServiceBase {
  final _state = ServerState();
  final _broadcastController = StreamController<LightUpdate>.broadcast();

  @override
  Future<ActivateLightResponse> activateLight(
    ActivateLightRequest request,
    ConnectContext context,
  ) async {
    // Validate request
    if (request.lightId.isEmpty) {
      throw ConnectException(
        Code.invalidArgument,
        'light_id is required',
      );
    }

    // Activate light
    final light = _state.activateLight(request);
    final activity = _state.recordActivity(
      lightId: request.lightId,
      userId: request.userId,
      type: ActivityType.ACTIVITY_TYPE_ACTIVATED,
      comment: request.comment,
    );

    // Broadcast update to all connected clients
    _broadcastController.add(LightUpdate(
      type: LightUpdate_UpdateType.UPDATE_TYPE_ACTIVATED,
      light: light,
      activity: activity,
    ));

    return ActivateLightResponse(
      light: light,
      activity: activity,
    );
  }

  @override
  Stream<LightUpdate> streamLightUpdates(
    Empty request,
    ConnectContext context,
  ) {
    // Return broadcast stream for real-time updates
    return _broadcastController.stream;
  }

  // ... other methods
}
```

### Client Side (Flutter)

```dart
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/http2.dart';
import 'package:lighten/gen/lighten/v1/light_service.connect.client.dart';
import 'package:lighten/gen/lighten/v1/state_service.connect.client.dart';

class LightenClient {
  late final Transport _transport;
  late final LightServiceClient _lightService;
  late final StateServiceClient _stateService;

  StreamSubscription? _updateSubscription;
  final _offlineQueue = <QueuedMessage>[];

  Future<void> connect(String serverUrl) async {
    _transport = Transport(
      baseUrl: serverUrl,
      codec: const ProtoCodec(), // or JsonCodec()
      httpClient: createHttpClient(),
    );

    _lightService = LightServiceClient(_transport);
    _stateService = StateServiceClient(_transport);

    // Connect and get initial state
    final response = await _stateService.connect(ConnectRequest(
      clientId: _generateClientId(),
      userName: 'User Name',
      role: UserRole.USER_ROLE_DOCTOR,
      version: '1.0.0',
    ));

    // Process initial state
    _processStateSnapshot(response.currentState);

    // Start listening for updates
    _startUpdateStream();

    // Start heartbeat
    _startHeartbeat();
  }

  void _startUpdateStream() {
    _updateSubscription = _lightService
        .streamLightUpdates(Empty())
        .listen(
          (update) => _handleLightUpdate(update),
          onError: (error) => _handleStreamError(error),
          onDone: () => _handleStreamDone(),
        );
  }

  Future<void> activateLight({
    required String lightId,
    required String userId,
    String? comment,
    LightPriority priority = LightPriority.LIGHT_PRIORITY_NORMAL,
  }) async {
    final request = ActivateLightRequest(
      lightId: lightId,
      userId: userId,
      comment: comment,
      priority: priority,
    );

    try {
      await _lightService.activateLight(request);
    } catch (e) {
      if (e is ConnectException) {
        if (e.code == Code.unavailable) {
          // Server offline, queue message
          _queueMessage(request);
          return;
        }
      }
      rethrow;
    }
  }

  void _queueMessage(dynamic message) {
    // Store in SQLite for persistence
    _offlineQueue.add(QueuedMessage(
      message: message,
      timestamp: DateTime.now(),
    ));
    _persistQueue();
  }

  Future<void> _processOfflineQueue() async {
    while (_offlineQueue.isNotEmpty) {
      final queued = _offlineQueue.first;

      try {
        // Replay message
        if (queued.message is ActivateLightRequest) {
          await _lightService.activateLight(queued.message);
        }
        // ... handle other message types

        _offlineQueue.removeAt(0);
        _persistQueue();
      } catch (e) {
        // Still offline, stop trying
        break;
      }
    }
  }

  // Persist queue to SQLite
  Future<void> _persistQueue() async {
    // Implementation using sqflite
  }
}
```

---

## mDNS Service Discovery

### Server Side (Publishing)

```dart
import 'package:multicast_dns/multicast_dns.dart';

class ServerDiscovery {
  final MDnsClient _mdns = MDnsClient();

  Future<void> publishService({
    required int port,
    required String serviceName,
  }) async {
    await _mdns.start();

    // Publish service
    final service = ResourceRecord.ptr(
      '_lighten._tcp.local',
      '$serviceName._lighten._tcp.local',
    );

    // Announce every 5 seconds
    Timer.periodic(Duration(seconds: 5), (_) {
      _mdns.lookup(service);
    });
  }
}
```

### Client Side (Discovery)

```dart
import 'package:multicast_dns/multicast_dns.dart';

class ClientDiscovery {
  Future<List<ServerInfo>> discoverServers({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final client = MDnsClient();
    await client.start();

    final servers = <ServerInfo>[];

    await for (final ptr in client
        .lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer('_lighten._tcp.local'),
        )
        .timeout(timeout)) {

      for (final srv in ptr.additionalRecords.whereType<SrvResourceRecord>()) {
        servers.add(ServerInfo(
          name: ptr.domainName,
          host: srv.target,
          port: srv.port,
        ));
      }
    }

    await client.stop();
    return servers;
  }
}

class ServerInfo {
  final String name;
  final String host;
  final int port;

  ServerInfo({
    required this.name,
    required this.host,
    required this.port,
  });

  String get url => 'http://$host:$port';
}
```

---

## Storage Adapter Pattern

### Abstract Storage Interface

```dart
/// Abstract storage adapter for persistence
/// Allows swapping implementations (SQLite, Hive, In-Memory, etc.)
abstract class StorageAdapter {
  /// Initialize the storage
  Future<void> init();

  /// Close/dispose the storage
  Future<void> close();

  /// Store a key-value pair
  Future<void> put(String key, Map<String, dynamic> value);

  /// Retrieve a value by key
  Future<Map<String, dynamic>?> get(String key);

  /// Delete a value by key
  Future<void> delete(String key);

  /// Get all values for a given prefix
  Future<List<Map<String, dynamic>>> getAll(String prefix);

  /// Delete all values for a given prefix
  Future<void> deleteAll(String prefix);

  /// Check if a key exists
  Future<bool> exists(String key);

  /// Clear all data
  Future<void> clear();
}
```

### SQLite Implementation

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class SqliteStorageAdapter implements StorageAdapter {
  Database? _db;

  @override
  Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'lighten_storage.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE storage('
          'key TEXT PRIMARY KEY, '
          'value TEXT NOT NULL, '
          'timestamp INTEGER NOT NULL'
          ')',
        );
      },
      version: 1,
    );
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await _db!.insert(
      'storage',
      {
        'key': key,
        'value': jsonEncode(value),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final results = await _db!.query(
      'storage',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;

    return jsonDecode(results.first['value'] as String) as Map<String, dynamic>;
  }

  @override
  Future<void> delete(String key) async {
    await _db!.delete('storage', where: 'key = ?', whereArgs: [key]);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String prefix) async {
    final results = await _db!.query(
      'storage',
      where: 'key LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'timestamp ASC',
    );

    return results
        .map((r) => jsonDecode(r['value'] as String) as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> deleteAll(String prefix) async {
    await _db!.delete('storage', where: 'key LIKE ?', whereArgs: ['$prefix%']);
  }

  @override
  Future<bool> exists(String key) async {
    final results = await _db!.query(
      'storage',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  @override
  Future<void> clear() async {
    await _db!.delete('storage');
  }
}
```

### Hive Implementation (Alternative)

```dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageAdapter implements StorageAdapter {
  Box? _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('lighten_storage');
  }

  @override
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await _box!.put(key, value);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final value = _box!.get(key);
    if (value == null) return null;
    return Map<String, dynamic>.from(value as Map);
  }

  @override
  Future<void> delete(String key) async {
    await _box!.delete(key);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String prefix) async {
    return _box!.keys
        .where((key) => key.toString().startsWith(prefix))
        .map((key) => Map<String, dynamic>.from(_box!.get(key) as Map))
        .toList();
  }

  @override
  Future<void> deleteAll(String prefix) async {
    final keysToDelete = _box!.keys
        .where((key) => key.toString().startsWith(prefix))
        .toList();
    await _box!.deleteAll(keysToDelete);
  }

  @override
  Future<bool> exists(String key) async {
    return _box!.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await _box!.clear();
  }
}
```

### In-Memory Implementation (Testing)

```dart
class InMemoryStorageAdapter implements StorageAdapter {
  final Map<String, Map<String, dynamic>> _store = {};

  @override
  Future<void> init() async {
    // No initialization needed
  }

  @override
  Future<void> close() async {
    _store.clear();
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    _store[key] = Map.from(value);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    return _store[key];
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String prefix) async {
    return _store.entries
        .where((e) => e.key.startsWith(prefix))
        .map((e) => e.value)
        .toList();
  }

  @override
  Future<void> deleteAll(String prefix) async {
    _store.removeWhere((key, _) => key.startsWith(prefix));
  }

  @override
  Future<bool> exists(String key) async {
    return _store.containsKey(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}
```

---

## Offline Queue with Storage Adapter

```dart
class QueuedMessage {
  final String id;
  final String messageType;
  final Map<String, dynamic> messageData;
  final DateTime timestamp;

  QueuedMessage({
    required this.id,
    required this.messageType,
    required this.messageData,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'messageType': messageType,
    'messageData': messageData,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory QueuedMessage.fromJson(Map<String, dynamic> json) => QueuedMessage(
    id: json['id'] as String,
    messageType: json['messageType'] as String,
    messageData: json['messageData'] as Map<String, dynamic>,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
  );
}

class OfflineQueue {
  final StorageAdapter _storage;
  static const _queuePrefix = 'queue:';

  OfflineQueue(this._storage);

  Future<void> init() async {
    await _storage.init();
  }

  Future<void> enqueue(String messageType, Map<String, dynamic> messageData) async {
    final message = QueuedMessage(
      id: _generateId(),
      messageType: messageType,
      messageData: messageData,
      timestamp: DateTime.now(),
    );

    await _storage.put('$_queuePrefix${message.id}', message.toJson());
  }

  Future<List<QueuedMessage>> getAll() async {
    final messages = await _storage.getAll(_queuePrefix);
    return messages.map((m) => QueuedMessage.fromJson(m)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> remove(String id) async {
    await _storage.delete('$_queuePrefix$id');
  }

  Future<void> clear() async {
    await _storage.deleteAll(_queuePrefix);
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (_) => chars[Random().nextInt(chars.length)]).join();
  }
}
```

---

## Storage Factory

```dart
enum StorageType {
  sqlite,
  hive,
  inMemory,
}

class StorageFactory {
  static StorageAdapter create(StorageType type) {
    switch (type) {
      case StorageType.sqlite:
        return SqliteStorageAdapter();
      case StorageType.hive:
        return HiveStorageAdapter();
      case StorageType.inMemory:
        return InMemoryStorageAdapter();
    }
  }
}
```

---

## Usage in Client

```dart
class LightenClient {
  late final Transport _transport;
  late final LightServiceClient _lightService;
  late final StateServiceClient _stateService;
  late final OfflineQueue _offlineQueue;

  StreamSubscription? _updateSubscription;

  // Dependency injection - storage adapter is provided
  LightenClient({
    required StorageAdapter storage,
  }) {
    _offlineQueue = OfflineQueue(storage);
  }

  Future<void> init() async {
    await _offlineQueue.init();
  }

  Future<void> connect(String serverUrl) async {
    _transport = Transport(
      baseUrl: serverUrl,
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );

    _lightService = LightServiceClient(_transport);
    _stateService = StateServiceClient(_transport);

    // Connect and get initial state
    final response = await _stateService.connect(ConnectRequest(
      clientId: _generateClientId(),
      userName: 'User Name',
      role: UserRole.USER_ROLE_DOCTOR,
      version: '1.0.0',
    ));

    // Process initial state
    _processStateSnapshot(response.currentState);

    // Process any queued offline messages
    await _processOfflineQueue();

    // Start listening for updates
    _startUpdateStream();

    // Start heartbeat
    _startHeartbeat();
  }

  Future<void> activateLight({
    required String lightId,
    required String userId,
    String? comment,
    LightPriority priority = LightPriority.LIGHT_PRIORITY_NORMAL,
  }) async {
    final request = ActivateLightRequest(
      lightId: lightId,
      userId: userId,
      comment: comment,
      priority: priority,
    );

    try {
      await _lightService.activateLight(request);
    } catch (e) {
      if (e is ConnectException) {
        if (e.code == Code.unavailable) {
          // Server offline, queue message
          await _queueMessage('activate_light', request.toProto3Json());
          return;
        }
      }
      rethrow;
    }
  }

  Future<void> _queueMessage(String messageType, Map<String, dynamic> messageData) async {
    await _offlineQueue.enqueue(messageType, messageData);
  }

  Future<void> _processOfflineQueue() async {
    final messages = await _offlineQueue.getAll();

    for (final message in messages) {
      try {
        // Replay message based on type
        switch (message.messageType) {
          case 'activate_light':
            final request = ActivateLightRequest()
              ..mergeFromProto3Json(message.messageData);
            await _lightService.activateLight(request);
            break;
          // ... handle other message types
        }

        // Success - remove from queue
        await _offlineQueue.remove(message.id);
      } catch (e) {
        // Still offline or error, stop trying
        break;
      }
    }
  }
}
```

---

## Usage Example

```dart
void main() async {
  // Production: Use SQLite
  final storage = StorageFactory.create(StorageType.sqlite);

  // Testing: Use in-memory
  // final storage = StorageFactory.create(StorageType.inMemory);

  final client = LightenClient(storage: storage);
  await client.init();
  await client.connect('http://localhost:8080');

  // ... use client
}
```

---

## Authentication Interface (Future)

```dart
// Abstract auth interface
abstract class AuthProvider {
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> clearToken();
}

// No-op implementation for MVP
class NoAuthProvider implements AuthProvider {
  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> setToken(String token) async {}

  @override
  Future<void> clearToken() async {}
}

// Future token-based implementation
class TokenAuthProvider implements AuthProvider {
  final Storage _storage;

  @override
  Future<String?> getToken() async {
    return _storage.read('auth_token');
  }

  @override
  Future<void> setToken(String token) async {
    await _storage.write('auth_token', token);
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete('auth_token');
  }
}

// Use interceptor to add auth headers
class AuthInterceptor extends Interceptor {
  final AuthProvider _authProvider;

  @override
  Future<UnaryResponse<O>> unary<I, O>(
    UnaryRequest<I> request,
    UnaryInvoker<I, O> next,
  ) async {
    final token = await _authProvider.getToken();
    if (token != null) {
      request.headers['authorization'] = 'Bearer $token';
    }
    return next(request);
  }
}
```

---

## Error Handling

ConnectRPC provides standardized error codes:

```dart
try {
  await client.activateLight(request);
} catch (e) {
  if (e is ConnectException) {
    switch (e.code) {
      case Code.unavailable:
        // Server offline
        _queueMessage(request);
        break;
      case Code.invalidArgument:
        // Invalid request
        _showError('Invalid light ID');
        break;
      case Code.notFound:
        // Light doesn't exist
        _showError('Light not found');
        break;
      case Code.permissionDenied:
        // Not authorized
        _showError('Permission denied');
        break;
      default:
        _showError('Unknown error: ${e.message}');
    }
  }
}
```

---

## Configuration

```dart
class ServerConfig {
  final int httpPort;
  final int grpcPort;
  final bool enableMdns;
  final String serviceName;

  const ServerConfig({
    this.httpPort = 8080,
    this.grpcPort = 5000,
    this.enableMdns = true,
    this.serviceName = 'Lighten Up Server',
  });
}

class ClientConfig {
  final String? serverUrl;  // null = use discovery
  final Duration connectionTimeout;
  final Duration heartbeatInterval;
  final bool enableOfflineQueue;

  const ClientConfig({
    this.serverUrl,
    this.connectionTimeout = const Duration(seconds: 10),
    this.heartbeatInterval = const Duration(seconds: 30),
    this.enableOfflineQueue = true,
  });
}
```

---

## Next Steps

1. ✅ Set up Buf CLI and buf.yaml
2. ✅ Define all .proto files
3. ✅ Generate Dart code with `buf generate`
4. ⬜ Implement server services
5. ⬜ Implement client connections
6. ⬜ Implement mDNS discovery
7. ⬜ Implement offline queue with SQLite
8. ⬜ Add interceptors for logging/monitoring
9. ⬜ Test with multiple clients
10. ⬜ Update TASK_BREAKDOWN.md with networking tasks

---

## Summary

**Protocol:** ConnectRPC (HTTP/1.1 or HTTP/2)
**Serialization:** Protocol Buffers (Protobuf)
**Streaming:** Bidirectional via ConnectRPC
**Discovery:** mDNS for auto-discovery, manual config fallback
**Offline Support:** SQLite queue with replay on reconnect
**Auth:** Interface-based, no auth for MVP
**Ports:** 8080 (HTTP), 5000 (gRPC alternative)
**State Sync:** Timestamp-based versioning

This design gives us:
- Type-safe APIs with compile-time checks
- Real-time updates via streaming
- Offline resilience with message queue
- Zero-config discovery via mDNS
- Future-proof authentication design
- Easy debugging with JSON codec option
- Small footprint (<100KB)
