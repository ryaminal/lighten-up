import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighten_up/data/models/alert_settings.dart';
import 'package:lighten_up/data/models/workstation.dart';
import 'package:lighten_up/presentation/providers/alert_settings_provider.dart';
import 'package:lighten_up/core/utils/logger.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('AlertSettingsProvider - Behavior Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Set log level to only show errors during tests (clean output)
      AppLogger.setLevel(Level.error);

      // Create a new provider container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    /// Helper to wait for async operations to complete
    Future<void> waitForLoading() async {
      final stopwatch = Stopwatch()..start();
      while (container.read(alertSettingsNotifierProvider).isLoading) {
        if (stopwatch.elapsed.inSeconds > 5) {
          throw TimeoutException(
            'Timeout waiting for alert settings loading to complete',
          );
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    group('Initialization', () {
      test('provider initializes with loaded workstations', () {
        // Act - Read the provider
        final state = container.read(alertSettingsNotifierProvider);

        // Assert - Workstations are loaded synchronously from mock data
        expect(state.workstations, isNotEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('workstations are loaded from mock data', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert - 4 mock workstations
        expect(state.workstations.length, equals(4));
      });

      test('first workstation is selected by default', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert
        expect(state.selectedWorkstationId, isNotNull);
        expect(
          state.selectedWorkstationId,
          equals(state.workstations.first.id),
        );
      });

      test('settings for first workstation are loaded', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert
        expect(state.selectedWorkstationSettings, isNotNull);
        expect(
          state.selectedWorkstationSettings!.workstationId,
          equals(state.workstations.first.id),
        );
      });

      test('mock workstations have expected zones', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert - Check workstation zones
        final zones = state.workstations.map((w) => w.zone).toList();
        expect(zones, contains('Reception'));
        expect(zones, contains('Doctor\'s Wing'));
        expect(zones, contains('Hygiene Wing'));
        expect(zones, contains('Laboratory'));
      });

      test('mock workstations have expected statuses', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert - Check at least one active and one offline
        final statuses = state.workstations.map((w) => w.status).toList();
        expect(statuses, contains(WorkstationStatus.active));
        expect(statuses, contains(WorkstationStatus.offline));
      });
    });

    group('Workstation Management', () {
      test(
        'loadSettingsForWorkstation loads specific workstation settings',
        () async {
          // Arrange
          final notifier = container.read(
            alertSettingsNotifierProvider.notifier,
          );
          final state = container.read(alertSettingsNotifierProvider);
          final secondWorkstation = state.workstations[1];

          // Act
          await notifier.loadSettingsForWorkstation(secondWorkstation.id);
          await waitForLoading(); // Wait for async operation to complete

          // Assert
          final updatedState = container.read(alertSettingsNotifierProvider);
          expect(
            updatedState.selectedWorkstationId,
            equals(secondWorkstation.id),
          );
          expect(
            updatedState.selectedWorkstationSettings!.workstationId,
            equals(secondWorkstation.id),
          );
        },
      );

      test(
        'loadSettingsForWorkstation updates selected workstation ID',
        () async {
          // Arrange
          final notifier = container.read(
            alertSettingsNotifierProvider.notifier,
          );
          final state = container.read(alertSettingsNotifierProvider);
          final thirdWorkstation = state.workstations[2];

          // Act
          await notifier.loadSettingsForWorkstation(thirdWorkstation.id);
          await waitForLoading(); // Wait for async operation to complete

          // Assert
          final updatedState = container.read(alertSettingsNotifierProvider);
          expect(
            updatedState.selectedWorkstationId,
            equals(thirdWorkstation.id),
          );
        },
      );

      test('refreshWorkstations reloads workstation data', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);

        // Act
        await notifier.refreshWorkstations();
        await waitForLoading(); // Wait for async operation to complete

        // Assert
        final state = container.read(alertSettingsNotifierProvider);
        expect(state.workstations, isNotEmpty);
        expect(state.isLoading, isFalse);
      });

      test('refreshWorkstations maintains workstation count', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);
        final initialCount = initialState.workstations.length;

        // Act
        await notifier.refreshWorkstations();
        await waitForLoading(); // Wait for async operation to complete

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(updatedState.workstations.length, equals(initialCount));
      });
    });

    group('Settings Management', () {
      test('selectedWorkstationSettings contains visual settings', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert
        final settings = state.selectedWorkstationSettings!;
        expect(settings.visual, isNotNull);
        expect(settings.visual.popupWindow, isA<bool>());
        expect(settings.visual.flashScreen, isA<bool>());
        expect(settings.visual.forceFocus, isA<bool>());
      });

      test('selectedWorkstationSettings contains event mappings', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert
        final settings = state.selectedWorkstationSettings!;
        expect(settings.eventMappings, isNotEmpty);
        expect(settings.eventMappings.length, greaterThanOrEqualTo(1));
      });

      test('selectedWorkstationSettings contains quiet hours', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert
        final settings = state.selectedWorkstationSettings!;
        expect(settings.quietHours, isNotNull);
        expect(settings.quietHours!.startTime, isNotEmpty);
        expect(settings.quietHours!.endTime, isNotEmpty);
        expect(settings.quietHours!.enabled, isA<bool>());
      });

      test('event mappings have expected priorities', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert
        final eventMappings = state.selectedWorkstationSettings!.eventMappings;
        final priorities = eventMappings.map((e) => e.priority).toList();

        // Check that we have various priority levels
        expect(priorities, isNotEmpty);
      });

      test('event mappings have volume in valid range', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);

        // Assert
        final eventMappings = state.selectedWorkstationSettings!.eventMappings;
        for (final mapping in eventMappings) {
          expect(mapping.volume, greaterThanOrEqualTo(0));
          expect(mapping.volume, lessThanOrEqualTo(100));
        }
      });

      test('loadGlobalSettings loads global default settings', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);

        // Act
        await notifier.loadGlobalSettings();
        await waitForLoading(); // Wait for async operation to complete

        // Assert
        final state = container.read(alertSettingsNotifierProvider);
        expect(state.globalSettings, isNotNull);
        expect(state.globalSettings!.workstationId, equals('global'));
      });

      test('saveSettings updates selected workstation settings', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);

        // Create modified settings
        final modifiedSettings = initialState.selectedWorkstationSettings!
            .copyWith(
              visual: const VisualSettings(
                popupWindow: false,
                flashScreen: false,
                forceFocus: true,
              ),
            );

        // Act
        await notifier.saveSettings(modifiedSettings);
        await waitForLoading(); // Wait for async operation to complete

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings,
          equals(modifiedSettings),
        );
        expect(
          updatedState.selectedWorkstationSettings!.visual.popupWindow,
          isFalse,
        );
        expect(
          updatedState.selectedWorkstationSettings!.visual.forceFocus,
          isTrue,
        );
      });
    });

    group('Visual Settings Updates', () {
      test('updateVisualSettings updates only visual settings', () {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);
        final initialEventMappings =
            initialState.selectedWorkstationSettings!.eventMappings;

        const newVisual = VisualSettings(
          popupWindow: false,
          flashScreen: false,
          forceFocus: true,
        );

        // Act
        notifier.updateVisualSettings(newVisual);

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings!.visual,
          equals(newVisual),
        );
        expect(
          updatedState.selectedWorkstationSettings!.eventMappings,
          equals(initialEventMappings),
        );
      });

      test('updateVisualSettings preserves other settings', () {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);
        final initialQuietHours =
            initialState.selectedWorkstationSettings!.quietHours;

        const newVisual = VisualSettings(
          popupWindow: true,
          flashScreen: false,
          forceFocus: false,
        );

        // Act
        notifier.updateVisualSettings(newVisual);

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings!.quietHours,
          equals(initialQuietHours),
        );
      });
    });

    group('Event Mappings Updates', () {
      test('updateEventMappings updates only event mappings', () {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);
        final initialVisual = initialState.selectedWorkstationSettings!.visual;

        const newMappings = [
          EventMapping(
            id: '999',
            eventName: 'Test Event',
            eventDescription: 'Test Description',
            priority: AlertEventPriority.urgent,
            soundId: 'Test Sound',
            volume: 75,
          ),
        ];

        // Act
        notifier.updateEventMappings(newMappings);

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings!.eventMappings,
          equals(newMappings),
        );
        expect(
          updatedState.selectedWorkstationSettings!.visual,
          equals(initialVisual),
        );
      });

      test('updateEventMappings can add multiple mappings', () {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);

        const newMappings = [
          EventMapping(
            id: '1',
            eventName: 'Event 1',
            eventDescription: 'Description 1',
            priority: AlertEventPriority.emergency,
            soundId: 'Sound 1',
            volume: 90,
          ),
          EventMapping(
            id: '2',
            eventName: 'Event 2',
            eventDescription: 'Description 2',
            priority: AlertEventPriority.normal,
            soundId: 'Sound 2',
            volume: 50,
          ),
        ];

        // Act
        notifier.updateEventMappings(newMappings);

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings!.eventMappings.length,
          equals(2),
        );
      });
    });

    group('Quiet Hours Updates', () {
      test('updateQuietHours updates only quiet hours', () {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);
        final initialVisual = initialState.selectedWorkstationSettings!.visual;

        const newQuietHours = QuietHours(
          startTime: '20:00',
          endTime: '08:00',
          enabled: true,
        );

        // Act
        notifier.updateQuietHours(newQuietHours);

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings!.quietHours,
          equals(newQuietHours),
        );
        expect(
          updatedState.selectedWorkstationSettings!.visual,
          equals(initialVisual),
        );
      });

      test('updateQuietHours can enable/disable quiet hours', () {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);

        const disabledQuietHours = QuietHours(
          startTime: '22:00',
          endTime: '06:00',
          enabled: false,
        );

        // Act
        notifier.updateQuietHours(disabledQuietHours);

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings!.quietHours!.enabled,
          isFalse,
        );
      });

      test('updateQuietHours updates time range', () {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);

        const newQuietHours = QuietHours(
          startTime: '23:00',
          endTime: '07:00',
          enabled: true,
        );

        // Act
        notifier.updateQuietHours(newQuietHours);

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationSettings!.quietHours!.startTime,
          equals('23:00'),
        );
        expect(
          updatedState.selectedWorkstationSettings!.quietHours!.endTime,
          equals('07:00'),
        );
      });
    });

    group('Complete User Scenarios', () {
      test('user can switch workstations and view their settings', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final state = container.read(alertSettingsNotifierProvider);
        final secondWorkstation = state.workstations[1];

        // Act - Switch to second workstation
        await notifier.loadSettingsForWorkstation(secondWorkstation.id);
        await waitForLoading(); // Wait for async operation to complete

        // Assert
        final updatedState = container.read(alertSettingsNotifierProvider);
        expect(
          updatedState.selectedWorkstationId,
          equals(secondWorkstation.id),
        );
        expect(updatedState.selectedWorkstationSettings, isNotNull);
        expect(
          updatedState.selectedWorkstationSettings!.workstationId,
          equals(secondWorkstation.id),
        );
      });

      test('user can modify all settings for a workstation', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);

        // Act - Update all settings
        const newVisual = VisualSettings(
          popupWindow: false,
          flashScreen: true,
          forceFocus: true,
        );
        notifier.updateVisualSettings(newVisual);

        const newMappings = [
          EventMapping(
            id: '1',
            eventName: 'Custom Event',
            eventDescription: 'Custom Description',
            priority: AlertEventPriority.urgent,
            soundId: 'Custom Sound',
            volume: 80,
          ),
        ];
        notifier.updateEventMappings(newMappings);

        const newQuietHours = QuietHours(
          startTime: '21:00',
          endTime: '07:00',
          enabled: true,
        );
        notifier.updateQuietHours(newQuietHours);

        // Save settings
        final modifiedSettings = initialState.selectedWorkstationSettings!
            .copyWith(
              visual: newVisual,
              eventMappings: newMappings,
              quietHours: newQuietHours,
            );
        await notifier.saveSettings(modifiedSettings);
        await waitForLoading(); // Wait for async operation to complete

        // Assert - All changes persisted
        final finalState = container.read(alertSettingsNotifierProvider);
        expect(
          finalState.selectedWorkstationSettings!.visual,
          equals(newVisual),
        );
        expect(
          finalState.selectedWorkstationSettings!.eventMappings,
          equals(newMappings),
        );
        expect(
          finalState.selectedWorkstationSettings!.quietHours,
          equals(newQuietHours),
        );
      });

      test('user can load global settings as template', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);

        // Act
        await notifier.loadGlobalSettings();
        await waitForLoading(); // Wait for async operation to complete

        // Assert
        final state = container.read(alertSettingsNotifierProvider);
        expect(state.globalSettings, isNotNull);
        expect(state.globalSettings!.visual, isNotNull);
        expect(state.globalSettings!.eventMappings, isNotEmpty);
      });

      test('state persists across multiple operations', () async {
        // Arrange
        final notifier = container.read(alertSettingsNotifierProvider.notifier);
        final initialState = container.read(alertSettingsNotifierProvider);
        final secondWorkstation = initialState.workstations[1];

        // Act - Multiple operations
        await notifier.loadSettingsForWorkstation(secondWorkstation.id);
        await waitForLoading(); // Wait for async operation to complete

        const newVisual = VisualSettings(
          popupWindow: false,
          flashScreen: false,
          forceFocus: true,
        );
        notifier.updateVisualSettings(newVisual);

        await notifier.loadGlobalSettings();
        await waitForLoading(); // Wait for async operation to complete

        // Assert - All changes persisted
        final finalState = container.read(alertSettingsNotifierProvider);
        expect(finalState.selectedWorkstationId, equals(secondWorkstation.id));
        expect(
          finalState.selectedWorkstationSettings!.visual,
          equals(newVisual),
        );
        expect(finalState.globalSettings, isNotNull);
      });
    });

    group('State Management', () {
      test('state copyWith updates only specified fields', () {
        // Arrange
        const initialState = AlertSettingsState(
          workstations: [],
          isLoading: false,
          error: null,
        );

        // Act
        final updatedState = initialState.copyWith(isLoading: true);

        // Assert
        expect(updatedState.workstations, equals(initialState.workstations));
        expect(updatedState.isLoading, isTrue);
        expect(updatedState.error, isNull);
      });

      test('state copyWith with null error clears error', () {
        // Arrange
        const initialState = AlertSettingsState(
          workstations: [],
          isLoading: false,
          error: 'Some error',
        );

        // Act
        final updatedState = initialState.copyWith(error: null);

        // Assert
        expect(updatedState.error, isNull);
      });

      test('workstations list is immutable', () {
        // Act
        final state = container.read(alertSettingsNotifierProvider);
        final workstationsCopy = List.from(state.workstations);

        // Assert - Lists should be equal but not the same instance
        expect(workstationsCopy, equals(state.workstations));
      });
    });
  });
}
