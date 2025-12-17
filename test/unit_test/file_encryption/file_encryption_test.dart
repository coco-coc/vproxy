import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vx/utils/file.dart';

void main() {
  test('test file encryption and decryption', () async {
    File('./test/unit_test/file_encryption/a.txt').writeAsStringSync('test');
    final inputFile = File('./test/unit_test/file_encryption/a.txt');
    print(inputFile.path);
    final encryptedFile = await encryptFile(inputFile, 'test');
    expect(await encryptedFile.exists(), true);
    final decryptedFile = await decryptFile(encryptedFile, 'test');
    expect(await decryptedFile.exists(), true);
    expect(await inputFile.readAsBytes(), await decryptedFile.readAsBytes());
    await encryptedFile.delete();
    await decryptedFile.delete();
    await inputFile.delete();
  });
}
