import 'dart:io';

Future<int> runCmds(List<String> args, String sudoPassword) async {
  final process = await Process.start('sudo', ['-S', ...args]);
  process.stdin.write('$sudoPassword\n');
  process.stdin.close();
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  return process.exitCode;
}
