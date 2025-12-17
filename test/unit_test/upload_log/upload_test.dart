
// void main() {
//   test('upload log', () async {
//     // create flutter_logs dir
//     final flutterLogDir = Directory('test/unit_test/upload_log/flutter_logs');
//     if (!flutterLogDir.existsSync()) {
//       flutterLogDir.createSync();
//     }
//     // write test file to flutter_logs dir
//     final testFile = File('${flutterLogDir.path}/test.txt');
//     testFile.writeAsStringSync('test');
//     // write test file to tunnel_logs dir
//     final testFile2 = File('${flutterLogDir.path}/latest.txt');
//     testFile2.writeAsStringSync('testLatest');

//     // create tunnel_logs dir
//     final tunnelLogDir = Directory('test/unit_test/upload_log/tunnel_logs');
//     if (!tunnelLogDir.existsSync()) {
//       tunnelLogDir.createSync();
//     }
//     // write test file to tunnel_logs dir
//     final testFile3 = File('${tunnelLogDir.path}/latest.txt');
//     testFile3.writeAsStringSync('testLatest');
//     final testFile4 = File('${tunnelLogDir.path}/test.txt');
//     testFile4.writeAsStringSync('test');

//     // create log upload service
//     await LogUploadService(
//       flutterLogDir: flutterLogDir,
//       tunnelLogDir: tunnelLogDir,
//     ).performUpload();
//   });
// }
