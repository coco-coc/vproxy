import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:vx/common/common.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/path.dart';
import 'package:vx/utils/upload_log.dart';

Future<String> getLogFileName() async {
  return "${(await PackageInfo.fromPlatform()).version}-${DateTime.now().toString().replaceAll(':', '_')}.txt";
}

Logger logger = Logger(
  level: Level.off,
);

/// used in production to report error that do not contain personal data
Logger reportLogger = Logger(
  level: Level.off,
);

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
        stackTrace: e.stack);
    reportLogger.e(
        "FlutterError: ${e.exception}. line: ${e.library}. summary: ${e.summary}.",
        error: e,
        stackTrace: e.stack);
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
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    reportLogger.e("Isolate.errorListener",
        stackTrace: errorAndStacktrace.last, error: errorAndStacktrace.first);
  }).sendPort);

  logUploadService = LogUploadService(
      flutterLogDir: await getFlutterLogDir(),
      tunnelLogDir: await getTunnelLogDir(),
      secret: logKey,
      uploadUrl: kDebugMode
          ? 'https://127.0.0.1:11111/api/upload-logs'
          : 'https://vproxybackend.5vnetwork.com:443/api/upload-logs');
  logUploadService!.start();
}

Future<void> setShareLog(bool value) async {
  persistentStateRepo.setShareLog(value);
  if (value) {
    await startShareLog();
  } else {
    await stopShareLog();
  }
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
  reportLogger = Logger(
    level: Level.off,
  );
  // } else {
  // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // }
  logUploadService?.stopPeriodicUpload();
  logUploadService = null;
}

Future<void> initLogger() async {
  if (isProduction()) {
    if (persistentStateRepo.shareLog == true) {
      await startShareLog();
    } else {
      await stopShareLog();
    }
  } else {
    final redirectStdErr = !kDebugMode && (Platform.isIOS || Platform.isMacOS);

    if (redirectStdErr) {
      final logDirPath = await getFlutterLogDir().then((value) => value.path);
      logger.d("redirectStdErr: $logDirPath");
      await darwinHostApi!.redirectStdErr(join(logDirPath, "redirect.txt"));
    }
    await setDebugLoggerDev();
    // In debug mode, output to both console and file
  }
}

Future<void> setDebugLoggerDev() async {
  final logDirPath = await getFlutterLogDir().then((value) => value.path);
  logger = Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(
        printTime:
            true) /* PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
       /*  colors: true */) */
    ,
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
  logger.d(
      'Logger initialized in debug mode - output to console and file: $logDirPath');
}

Future<void> setReportLogger() async {
  reportLogger = Logger(
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
      path: await getFlutterLogDir().then((value) => value.path),
      latestFileName: 'latest.txt',
      fileNameFormatter: (DateTime date) {
        return '${date.year}-${date.month}-${date.day}.txt';
      },
    ),
  );
}

Future<void> setDebugLoggerProduction() async {
  final logDirPath = await getFlutterLogDir().then((value) => value.path);
  logger = Logger(
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
  logger.d(
      'Logger initialized in debug mode - output to console and file: $logDirPath');
}

Future<void> unsetDebugLoggerProduction() async {
  final oldLogger = logger;
  logger = Logger(
    level: Level.off,
  );
  await oldLogger.close();
}
