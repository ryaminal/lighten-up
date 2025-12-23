import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  /// Current log level - can be changed at runtime (useful for tests)
  ///
  /// Log levels (from most to least verbose):
  /// - Level.all: Show all logs
  /// - Level.trace: Very detailed logs
  /// - Level.debug: Debug information
  /// - Level.info: General information
  /// - Level.warning: Warning messages
  /// - Level.error: Error messages
  /// - Level.fatal: Fatal errors only
  /// - Level.off: No logs
  ///
  /// Example: Set to Level.error in tests to only show errors
  static Level level = Level.debug;

  static Logger _logger = _createLogger();

  static Logger _createLogger() {
    return Logger(
      level: level,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// Updates the log level and recreates the logger
  ///
  /// Call this in test setUp to configure logging:
  /// ```dart
  /// setUp(() {
  ///   AppLogger.setLevel(Level.error); // Only show errors
  /// });
  /// ```
  static void setLevel(Level newLevel) {
    level = newLevel;
    _logger = _createLogger();
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
