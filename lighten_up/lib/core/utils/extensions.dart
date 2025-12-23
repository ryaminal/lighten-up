import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(this);
  }

  bool get isNumeric {
    return double.tryParse(this) != null;
  }
}

extension DateTimeExtensions on DateTime {
  /// Formats date as DD/MM/YYYY
  String toFormattedString() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Formats time as 12-hour format with AM/PM (e.g., "3:45 PM")
  String toTimeString() {
    final hour = this.hour > 12
        ? this.hour - 12
        : this.hour == 0
        ? 12
        : this.hour;
    final period = this.hour >= 12 ? 'PM' : 'AM';
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Alias for toTimeString() for consistency
  String to12HourString() => toTimeString();

  /// Formats time as 24-hour format (e.g., "15:45")
  String to24HourString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formats time with seconds as 24-hour format (e.g., "15:45:30")
  String to24HourStringWithSeconds() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

extension DurationExtensions on Duration {
  /// Formats duration as human-readable string (e.g., "2h 30m", "45m 15s", "30s")
  String toReadableString() {
    if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    } else if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    } else {
      return '${inSeconds}s';
    }
  }

  /// Formats duration as MM:SS timer display (e.g., "05:30")
  String toTimerDisplay() {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Formats duration as HH:MM:SS (e.g., "01:05:30")
  String toHourMinuteSecond() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

extension TimeOfDayExtensions on TimeOfDay {
  /// Formats TimeOfDay as 24-hour format (e.g., "15:45")
  String to24HourString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formats TimeOfDay as 12-hour format with AM/PM (e.g., "3:45 PM")
  String to12HourString() {
    final hour12 = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }
}

/// BuildContext extensions for common UI operations
extension ContextExtensions on BuildContext {
  /// Show error SnackBar with red background
  void showError(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success SnackBar with green background
  void showSuccess(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.alertGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info SnackBar with default background
  void showInfo(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
}
