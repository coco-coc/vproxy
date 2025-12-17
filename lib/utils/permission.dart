import 'dart:io';

Future<int> userId() async {
  if (Platform.isLinux) {
    return await Process.run('id', ['-u']).then((value) => int.parse(value.stdout));
  }
  return 0;
}

Future<int> groupId() async {
  if (Platform.isLinux) {
    return await Process.run('id', ['-g']).then((value) => int.parse(value.stdout));
  }
  return 0;
}