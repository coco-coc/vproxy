// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/path.dart';
import 'package:flutter_common/types/logger.dart' as common;

class LoggerWrapper implements common.Logger {
  Logger? _logger;
  LoggerWrapper({Logger? logger}) {
    _logger = logger;
  }

  set logger(Logger? value) {
    _logger?.close();
    _logger = value;
  }

  @override
  void t(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger?.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void d(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger?.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void i(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger?.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger?.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger?.e(message, time: time, error: error, stackTrace: stackTrace);
  }
}

LoggerWrapper logger = LoggerWrapper();

/// used in production to report error that do not contain personal data
LoggerWrapper reportLogger = LoggerWrapper();

class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiOutput(this.outputs);

  @override
  Future<void> init() async {
    for (var output in outputs) {
      await output.init();
    }
  }

  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }

  @override
  Future<void> destroy() async {
    for (var output in outputs) {
      await output.destroy();
    }
  }
}

bool isProduction() {
  if (demo) {
    return true;
  }
  if (Platform.isWindows || Platform.isLinux) {
    return kReleaseMode;
  }
  return (appFlavor == "production" ||
          appFlavor == "pkg" ||
          appFlavor == "apk") &&
      kReleaseMode;
}

Future<void> startShareLog() async {
  // if (Platform.isWindows) {
  await setReportLogger();
  // } else {
  //   FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  //   // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (FlutterErrorDetails e) {
    logger.e(
      "FlutterError: ${e.exception}. line: ${e.library}. summary: ${e.summary}.",
      error: e,
      stackTrace: e.stack,
    );
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   if (error is SqliteException) {
  //     if (error.extendedResultCode == 5) {
  //       return false;
  //     }
  //   }
  //   if (error.toString().contains('UUID')) {
  //     return false;
  //   }
  //   reportLogger.e("PlatformDispatcher.instance.onError",
  //       stackTrace: stack, error: error);
  //   return true;
  // };
  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      reportLogger.e(
        "Isolate.errorListener",
        stackTrace: errorAndStacktrace.last,
        error: errorAndStacktrace.first,
      );
    }).sendPort,
  );
}

Future<void> reportError(String message, dynamic error) async {
  // if (Platform.isWindows) {
  reportLogger.e(message, error: error);
  // } else {
  // await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  // }
}

Future<void> stopShareLog() async {
  // if (Platform.isWindows) {
  reportLogger.logger = null;
  // } else {
  // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // }
}

Future<void> initLogger(SharedPreferences pref) async {
  if (isProduction()) {
    if (pref.shareLog == true) {
      await startShareLog();
    }
  } else {
    final redirectStdErr = !kDebugMode && (Platform.isIOS || Platform.isMacOS);
    if (redirectStdErr) {
      final logDirPath = getFlutterLogDir().path;
      logger.d("redirectStdErr: $logDirPath");
      await darwinHostApi!.redirectStdErr(join(logDirPath, "redirect.txt"));
    }
    await setDebugLoggerDevlopment();
  }
}

Future<void> setDebugLoggerDevlopment() async {
  final logDirPath = getFlutterLogDir().path;
  final l = Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(printTime: true) /* PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
       /*  colors: true */) */,
    output: MultiOutput([
      // if (!kDebugMode)
      AdvancedFileOutput(
        path: logDirPath,
        writeImmediately: [Level.debug],
        latestFileName: 'latest.txt',
      ),
      ConsoleOutput(),
    ]),
    level: Level.debug,
  );
  logger.logger = l;
  logger.d(
    'Logger initialized in debug mode - output to console and file: $logDirPath',
  );
}

Future<void> setReportLogger() async {
  final l = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      // Should each log print contain a timestamp
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.error,
    output: AdvancedFileOutput(
      writeImmediately: [Level.error],
      path: getFlutterLogDir().path,
      latestFileName: 'latest.txt',
      fileNameFormatter: (DateTime date) {
        return '${date.year}-${date.month}-${date.day}.txt';
      },
    ),
  );
  reportLogger.logger = l;
}

Future<void> setDebugLoggerProduction() async {
  final logDirPath = getFlutterLogDir().path;
  final l = Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(printTime: true),
    output: AdvancedFileOutput(
      writeImmediately: [Level.error],
      path: await getDebugFlutterLogDir().then((value) => value.path),
      latestFileName: 'latest.txt',
      fileNameFormatter: (DateTime date) {
        return '${date.year}-${date.month}-${date.day}.txt';
      },
    ),
    level: Level.debug,
  );
  logger.logger = l;
  logger.d(
    'Logger initialized in debug mode - output to console and file: $logDirPath',
  );
}

Future<void> unsetDebugLoggerProduction() async {
  logger.logger = null;
}
