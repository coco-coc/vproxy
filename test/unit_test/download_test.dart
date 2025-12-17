import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:vx/utils/download.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<StreamedResponse>()])
import 'download_test.mocks.dart';

void main() {
  group('directDownloadToFile', () {
    late MockClient mockClient;
    late String tempDir;

    setUp(() async {
      mockClient = MockClient();
      tempDir = Directory.systemTemp.createTempSync().path;
      // Provide dummy value for ByteStream
      provideDummy<ByteStream>(ByteStream.fromBytes([]));
    });

    tearDown(() {
      Directory(tempDir).deleteSync(recursive: true);
    });

    test('successfully downloads and saves file', () async {
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final destPath = '$tempDir/test.dat';

      // Create mock streamed response
      final mockResponse = MockStreamedResponse();
      final byteStream = ByteStream(Stream.value(testData));
      when(mockResponse.stream).thenAnswer((_) => byteStream);
      when(mockResponse.statusCode).thenReturn(200);

      // Mock the send request
      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      await directDownloadToFile(
        'https://example.com/file',
        destPath,
        mockClient,
      );

      // Verify file was saved correctly
      final savedFile = File(destPath);
      expect(await savedFile.exists(), true);
      expect(await savedFile.readAsBytes(), equals(testData));
    });

    test('handles download failure', () async {
      final destPath = '$tempDir/test.dat';

      // Mock failed response
      when(mockClient.send(any)).thenThrow(Exception('Download failed'));

      // Verify download throws exception
      expect(
        () => directDownloadToFile(
            'https://example.com/file', destPath, mockClient),
        throwsException,
      );

      // Verify no file was created
      final savedFile = File(destPath);
      expect(await savedFile.exists(), false);
    });

    test('handles stream error', () async {
      final destPath = '$tempDir/test.dat';

      // Create mock streamed response with error
      final mockResponse = MockStreamedResponse();
      final errorStream = ByteStream(Stream.error(Exception('Stream error')));
      when(mockResponse.stream).thenAnswer((_) => errorStream);
      when(mockResponse.statusCode).thenReturn(200);

      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      // Verify stream error throws exception
      expect(
        () => directDownloadToFile(
            'https://example.com/file', destPath, mockClient),
        throwsException,
      );

      // Verify no file was created
      final savedFile = File(destPath);
      expect(await savedFile.exists(), false);
    });

    test('handles invalid status code', () async {
      final destPath = '$tempDir/test.dat';

      // Create mock streamed response with error status
      final mockResponse = MockStreamedResponse();
      when(mockResponse.statusCode).thenReturn(404);

      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      // Verify invalid status throws exception
      expect(
        () => directDownloadToFile(
            'https://example.com/file', destPath, mockClient),
        throwsException,
      );
    });

    test('temp file is cleaned up after failure', () async {
      final destPath = '$tempDir/test.dat';

      // Create mock response that will fail during streaming
      final mockResponse = MockStreamedResponse();
      final errorStream = ByteStream(Stream.error(Exception('Stream error')));
      when(mockResponse.stream).thenAnswer((_) => errorStream);
      when(mockResponse.statusCode).thenReturn(200);

      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      try {
        await directDownloadToFile(
          'https://example.com/file',
          destPath,
          mockClient,
        );
      } catch (_) {}

      // Verify no temp files are left
      final tempFiles = Directory(tempDir)
          .listSync()
          .where((f) => f.path.contains('.tmp.'))
          .toList();
      expect(tempFiles, isEmpty);
    });
  });
}
