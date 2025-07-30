import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error, success }

class Logger {
  static bool _isEnabled = true;
  static LogLevel _minLevel = LogLevel.debug;

  // Enable/disable logging
  static void enable() => _isEnabled = true;
  static void disable() => _isEnabled = false;

  // Set minimum log level
  static void setMinLevel(LogLevel level) => _minLevel = level;

  // Debug logging
  static void logDebug(String message, [dynamic error]) {
    _log(LogLevel.debug, message, error);
  }

  // Info logging
  static void logInfo(String message, [dynamic error]) {
    _log(LogLevel.info, message, error);
  }

  // Warning logging
  static void logWarning(String message, [dynamic error]) {
    _log(LogLevel.warning, message, error);
  }

  // Error logging
  static void logError(String message, [dynamic error]) {
    _log(LogLevel.error, message, error);
  }

  // Success logging
  static void logSuccess(String message, [dynamic error]) {
    _log(LogLevel.success, message, error);
  }

  // Network request logging
  static void logRequest(String method, String url, [Map<String, String>? headers]) {
    if (_shouldLog(LogLevel.info)) {
      final headerStr = headers != null ? ' Headers: $headers' : '';
      _log(LogLevel.info, '🌐 $method $url$headerStr');
    }
  }

  // Network response logging
  static void logResponse(int statusCode, String url, [dynamic body]) {
    if (_shouldLog(LogLevel.info)) {
      final statusEmoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      final bodyStr = body != null ? ' Body: ${body.toString().length > 100 ? '${body.toString().substring(0, 100)}...' : body}' : '';
      _log(LogLevel.info, '$statusEmoji Response $statusCode from $url$bodyStr');
    }
  }

  // API operation logging
  static void logApiOperation(String operation, {String? details}) {
    if (_shouldLog(LogLevel.info)) {
      final detailStr = details != null ? ' - $details' : '';
      _log(LogLevel.info, '🔄 API: $operation$detailStr');
    }
  }

  // Cache logging
  static void logCache(String action, String key) {
    if (_shouldLog(LogLevel.debug)) {
      _log(LogLevel.debug, '💾 Cache $action: $key');
    }
  }

  // Performance logging
  static void logPerformance(String operation, Duration duration) {
    if (_shouldLog(LogLevel.info)) {
      _log(LogLevel.info, '⏱️ Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  // Private logging method
  static void _log(LogLevel level, String message, [dynamic error]) {
    if (!_isEnabled || !_shouldLog(level)) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = _getLevelString(level);
    final emoji = _getLevelEmoji(level);

    String logMessage = '$emoji [$timestamp] $levelStr: $message';

    if (error != null) {
      logMessage += '\nError: $error';
      if (error is Error) {
        logMessage += '\nStackTrace: ${error.stackTrace}';
      }
    }

    // Use developer.log for better Flutter DevTools integration
    developer.log(
      logMessage,
      name: 'KarbarShop',
      level: _getDeveloperLogLevel(level),
      error: error,
    );

    // Also print to console for development
    if (level == LogLevel.error) {
      print('\x1B[31m$logMessage\x1B[0m'); // Red color for errors
    } else if (level == LogLevel.warning) {
      print('\x1B[33m$logMessage\x1B[0m'); // Yellow color for warnings
    } else if (level == LogLevel.success) {
      print('\x1B[32m$logMessage\x1B[0m'); // Green color for success
    } else {
      print(logMessage);
    }
  }

  static bool _shouldLog(LogLevel level) {
    return level.index >= _minLevel.index;
  }

  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.success:
        return 'SUCCESS';
    }
  }

  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.success:
        return '✅';
    }
  }

  static int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.success:
        return 800;
    }
  }

  // Utility method to time operations
  static Future<T> timeOperation<T>(
      String operationName,
      Future<T> Function() operation,
      ) async {
    final stopwatch = Stopwatch()..start();
    try {
      logInfo('Starting operation: $operationName');
      final result = await operation();
      stopwatch.stop();
      logPerformance(operationName, stopwatch.elapsed);
      logSuccess('Completed operation: $operationName');
      return result;
    } catch (error) {
      stopwatch.stop();
      logError('Failed operation: $operationName', error);
      rethrow;
    }
  }
}