import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:vx/utils/upload_log.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client])
import 'upload_log_test.mocks.dart';

void main() {
  late LogUploadService logUploadService;
  late Directory flutterLogDir;
  late Directory tunnelLogDir;
  late MockClient mockHttpClient;

  setUp(() async {
    flutterLogDir = await Directory.systemTemp.createTemp('flutter_logs');
    tunnelLogDir = await Directory.systemTemp.createTemp('tunnel_logs');
    mockHttpClient = MockClient();
    logUploadService = LogUploadService(
      flutterLogDir: flutterLogDir,
      tunnelLogDir: tunnelLogDir,
      uploadUrl:
          'https://api.github.com/repos/5vnetwork/vx/releases/latest',
      secret: 'test',
    );
  });

  tearDown(() async {
    await flutterLogDir.delete(recursive: true);
    await tunnelLogDir.delete(recursive: true);
  });

  group('LogUploadService', () {
    test('initializes correctly', () async {
      await logUploadService.start();
      expect(logUploadService, isNotNull);
    });

    test('starts and stops periodic upload', () {
      logUploadService.startPeriodicUpload();
      expect(logUploadService, isNotNull);

      logUploadService.stopPeriodicUpload();
      expect(logUploadService, isNotNull);
    });

    test('collects log data from empty directories', () async {
      final logData = await logUploadService.collectLogData();
      expect(logData, isNull);
    });

    test('collects log data from directories with files', () async {
      // Create test log files
      final flutterLogFile = File('${flutterLogDir.path}/test.log');
      await flutterLogFile.writeAsString('test flutter log content');

      final tunnelLogFile = File('${tunnelLogDir.path}/test.log');
      await tunnelLogFile.writeAsString('test tunnel log content');

      final logData = await logUploadService.collectLogData();
      expect(logData, isNotNull);
      expect(logData?.flutterLog, isNotEmpty);
      expect(logData?.tunnelLog, isNotEmpty);
    });

    test('handles non-existent files gracefully', () async {
      final logData = await logUploadService.collectLogData();
      expect(logData, isNull);
    });

    test('uploads log data successfully', () async {
      // Create test log files
      final flutterLogFile = File('${flutterLogDir.path}/test.log');
      await flutterLogFile.writeAsString('test flutter log content');

      final tunnelLogFile = File('${tunnelLogDir.path}/test.log');
      await tunnelLogFile.writeAsString('test tunnel log content');

      // Mock successful HTTP response
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('success', 200));

      final logData = await logUploadService.collectLogData();
      expect(logData, isNotNull);

      await logUploadService.uploadLogData(logData!, 1);
    });

    test('handles upload failure with retry', () async {
      // Create test log files
      final flutterLogFile = File('${flutterLogDir.path}/test.log');
      await flutterLogFile.writeAsString('test flutter log content');

      final tunnelLogFile = File('${tunnelLogDir.path}/test.log');
      await tunnelLogFile.writeAsString('test tunnel log content');

      // Mock failed HTTP response
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('error', 500));

      final logData = await logUploadService.collectLogData();
      expect(logData, isNotNull);

      expect(
        () => logUploadService.uploadLogData(logData!, 1),
        throwsA(isA<HttpException>()),
      );
    });

    test('handles upload timeout', () async {
      // Create test log files
      final flutterLogFile = File('${flutterLogDir.path}/test.log');
      await flutterLogFile.writeAsString('test flutter log content');

      final tunnelLogFile = File('${tunnelLogDir.path}/test.log');
      await tunnelLogFile.writeAsString('test tunnel log content');

      // Mock timeout
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => Future.delayed(const Duration(seconds: 31)));

      final logData = await logUploadService.collectLogData();
      expect(logData, isNotNull);

      expect(
        () => logUploadService.uploadLogData(logData!, 1),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
  
  
  
}
