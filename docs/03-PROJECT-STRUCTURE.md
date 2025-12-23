# BlueNote Flutter Project Structure

## Project Root Structure

```
bluenote/
├── lib/
│   ├── core/                      # Core utilities and shared resources
│   ├── data/                      # Data layer
│   ├── domain/                    # Domain/business logic layer
│   ├── presentation/              # UI layer
│   ├── routes/                    # Navigation and routing
│   └── main.dart                  # App entry point
├── test/                          # Unit and widget tests
├── integration_test/              # Integration tests
├── assets/                        # Static assets
│   ├── images/
│   ├── icons/
│   ├── sounds/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

---

## Detailed Directory Structure

### `/lib/core/`
Core utilities, constants, and shared functionality.

```
lib/core/
├── constants/
│   ├── app_colors.dart           # Color palette
│   ├── app_dimensions.dart       # Spacing, sizes
│   ├── app_strings.dart          # Static strings
│   └── app_routes.dart           # Route constants
├── theme/
│   ├── app_theme.dart            # Theme data
│   ├── dark_theme.dart           # Dark theme config
│   └── light_theme.dart          # Light theme config
├── utils/
│   ├── date_formatter.dart       # Date/time utilities
│   ├── validators.dart           # Input validation
│   ├── extensions.dart           # Dart extensions
│   └── logger.dart               # Logging utility
├── network/
│   ├── api_client.dart           # Dio HTTP client
│   ├── api_endpoints.dart        # API URL constants
│   ├── api_interceptor.dart      # Request/response interceptors
│   └── websocket_client.dart     # WebSocket handler
├── storage/
│   ├── secure_storage.dart       # Secure storage wrapper
│   ├── preferences_storage.dart  # SharedPreferences wrapper
│   └── database_helper.dart      # Hive/SQLite helper
├── error/
│   ├── failures.dart             # Failure types
│   └── exceptions.dart           # Custom exceptions
└── widgets/                       # Global reusable widgets
    ├── app_button.dart
    ├── app_text_field.dart
    ├── loading_indicator.dart
    └── error_widget.dart
```

### `/lib/data/`
Data layer with repositories, data sources, and models.

```
lib/data/
├── models/                        # Data transfer objects (DTOs)
│   ├── alert_model.dart
│   ├── room_model.dart
│   ├── user_model.dart
│   ├── message_model.dart
│   ├── workstation_model.dart
│   └── conversation_model.dart
├── repositories/                  # Repository implementations
│   ├── alert_repository_impl.dart
│   ├── room_repository_impl.dart
│   ├── user_repository_impl.dart
│   ├── chat_repository_impl.dart
│   └── analytics_repository_impl.dart
└── datasources/                   # Data sources
    ├── remote/
    │   ├── alert_remote_datasource.dart
    │   ├── room_remote_datasource.dart
    │   ├── user_remote_datasource.dart
    │   ├── chat_remote_datasource.dart
    │   └── analytics_remote_datasource.dart
    └── local/
        ├── alert_local_datasource.dart
        ├── room_local_datasource.dart
        ├── user_local_datasource.dart
        └── chat_local_datasource.dart
```

### `/lib/domain/`
Domain layer with entities, repositories, and use cases.

```
lib/domain/
├── entities/                      # Business entities
│   ├── alert.dart
│   ├── room.dart
│   ├── user.dart
│   ├── message.dart
│   ├── workstation.dart
│   ├── conversation.dart
│   └── alert_settings.dart
├── repositories/                  # Repository interfaces
│   ├── alert_repository.dart
│   ├── room_repository.dart
│   ├── user_repository.dart
│   ├── chat_repository.dart
│   └── analytics_repository.dart
└── usecases/                      # Business logic use cases
    ├── alerts/
    │   ├── get_alerts.dart
    │   ├── acknowledge_alert.dart
    │   ├── update_alert_settings.dart
    │   └── test_alert.dart
    ├── rooms/
    │   ├── get_rooms.dart
    │   ├── get_room_status.dart
    │   └── activate_light.dart
    ├── chat/
    │   ├── get_conversations.dart
    │   ├── send_message.dart
    │   ├── mark_as_read.dart
    │   └── upload_attachment.dart
    ├── analytics/
    │   ├── get_daily_metrics.dart
    │   ├── get_activity_logs.dart
    │   └── export_report.dart
    └── auth/
        ├── login.dart
        ├── logout.dart
        └── unlock_station.dart
```

### `/lib/presentation/`
UI layer with screens, widgets, and view models.

```
lib/presentation/
├── providers/                     # Riverpod providers
│   ├── alert_provider.dart
│   ├── room_provider.dart
│   ├── user_provider.dart
│   ├── chat_provider.dart
│   ├── theme_provider.dart
│   └── auth_provider.dart
├── screens/                       # Main screens
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── widgets/
│   │   │   ├── room_card.dart
│   │   │   ├── zone_filter_chips.dart
│   │   │   └── broadcast_panel.dart
│   │   └── dashboard_view_model.dart
│   ├── alerts/
│   │   ├── alert_settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── workstation_selector.dart
│   │   │   ├── sound_palette.dart
│   │   │   ├── event_mapping_table.dart
│   │   │   └── visual_settings_card.dart
│   │   └── alert_settings_view_model.dart
│   ├── analytics/
│   │   ├── analytics_screen.dart
│   │   ├── widgets/
│   │   │   ├── kpi_card.dart
│   │   │   ├── busy_hours_chart.dart
│   │   │   ├── type_distribution_chart.dart
│   │   │   └── activity_log_table.dart
│   │   └── analytics_view_model.dart
│   ├── dock/
│   │   ├── notification_dock.dart
│   │   ├── widgets/
│   │   │   ├── alert_card.dart
│   │   │   ├── status_toggle.dart
│   │   │   └── dock_header.dart
│   │   └── dock_view_model.dart
│   ├── chat/
│   │   ├── chat_screen.dart
│   │   ├── conversation_list_screen.dart
│   │   ├── widgets/
│   │   │   ├── conversation_card.dart
│   │   │   ├── message_bubble.dart
│   │   │   ├── chat_input.dart
│   │   │   └── quick_action_chips.dart
│   │   └── chat_view_model.dart
│   ├── lock/
│   │   ├── lock_screen.dart
│   │   ├── widgets/
│   │   │   ├── pin_input.dart
│   │   │   └── numpad.dart
│   │   └── lock_view_model.dart
│   └── auth/
│       ├── login_screen.dart
│       ├── widgets/
│       │   └── login_form.dart
│       └── login_view_model.dart
└── shared/                        # Shared UI components
    ├── layouts/
    │   ├── app_scaffold.dart
    │   ├── responsive_layout.dart
    │   └── sidebar_layout.dart
    └── widgets/
        ├── app_sidebar.dart
        ├── app_app_bar.dart
        ├── app_drawer.dart
        ├── status_badge.dart
        ├── avatar_widget.dart
        └── loading_overlay.dart
```

### `/lib/routes/`
Navigation and routing configuration.

```
lib/routes/
├── app_router.dart               # go_router configuration
├── route_guards.dart             # Auth guards
└── route_transitions.dart        # Custom transitions
```

### `/lib/main.dart`
App entry point.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  // await initializeServices();

  runApp(
    const ProviderScope(
      child: BlueNoteApp(),
    ),
  );
}

class BlueNoteApp extends ConsumerWidget {
  const BlueNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'BlueNote',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## Test Directory Structure

```
test/
├── unit/                          # Unit tests
│   ├── core/
│   ├── data/
│   ├── domain/
│   └── presentation/
├── widget/                        # Widget tests
│   ├── screens/
│   └── widgets/
└── fixtures/                      # Test fixtures and mocks
    ├── models/
    └── responses/
```

---

## Assets Directory Structure

```
assets/
├── images/
│   ├── logo.png
│   ├── splash.png
│   └── placeholders/
├── icons/
│   └── app_icon.png
├── sounds/
│   ├── chime.mp3
│   ├── urgent.mp3
│   ├── sonar.mp3
│   └── ding_dong.mp3
└── fonts/
    └── Inter/
        ├── Inter-Regular.ttf
        ├── Inter-Medium.ttf
        ├── Inter-SemiBold.ttf
        └── Inter-Bold.ttf
```

---

## Key Files and Their Responsibilities

### `main.dart`
- App initialization
- Provider setup
- Root widget configuration

### `app_router.dart`
- Route definitions
- Navigation configuration
- Deep linking setup

### `app_theme.dart`
- Theme configuration
- Color schemes
- Typography
- Component themes

### `api_client.dart`
- HTTP client setup
- Base URL configuration
- Interceptors setup
- Error handling

### `*_provider.dart`
- State management
- Business logic coordination
- Data fetching and caching

### `*_repository_impl.dart`
- Data source orchestration
- API call implementation
- Local storage operations
- Data transformation

### `*_view_model.dart` (if using MVVM pattern)
- Screen state management
- User interaction handling
- Business logic calls

---

## File Naming Conventions

1. **Dart files**: snake_case (e.g., `user_profile.dart`)
2. **Classes**: PascalCase (e.g., `UserProfile`)
3. **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_RETRY_ATTEMPTS`)
4. **Private members**: Prefix with `_` (e.g., `_privateMethod`)
5. **Assets**: kebab-case (e.g., `user-avatar.png`)

---

## Import Organization

Follow this order for imports:

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter framework imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party package imports
import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';

// 4. Project imports (absolute)
import 'package:bluenote/core/constants/app_colors.dart';
import 'package:bluenote/domain/entities/user.dart';

// 5. Relative imports (only within same feature)
import '../widgets/custom_button.dart';
```

---

## Configuration Files

### `pubspec.yaml`
```yaml
name: bluenote
description: Medical office communication and notification system
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Navigation
  go_router: ^13.0.0

  # UI
  flutter_animate: ^4.5.0
  cached_network_image: ^3.3.0

  # Charts
  fl_chart: ^0.66.0

  # Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # Network
  dio: ^5.4.0
  web_socket_channel: ^2.4.0

  # Utilities
  intl: ^0.18.1
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  mockito: ^5.4.4

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/sounds/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter/Inter-Regular.ttf
        - asset: assets/fonts/Inter/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter/Inter-Bold.ttf
          weight: 700
```

### `analysis_options.yaml`
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_single_quotes
    - always_declare_return_types
    - require_trailing_commas
```

---

## Build Configurations

### Development
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### Staging
```bash
flutter run --flavor staging -t lib/main_staging.dart
```

### Production
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

---

## Next Steps

1. Initialize Flutter project
2. Set up project structure
3. Configure dependencies
4. Implement core utilities
5. Build theme system
6. Create base widgets
7. Implement data layer
8. Build screens iteratively
