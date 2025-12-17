import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vx/app/settings/setting.dart';
import 'package:vx/common/common.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/path.dart';
import 'package:vx/utils/upload_log.dart';
import 'package:vx/widgets/circular_progress_indicator.dart';
import 'package:vx/widgets/form_dialog.dart';

class DebugLogPage extends StatefulWidget {
  const DebugLogPage({super.key, this.showAppBar = true});
  final bool showAppBar;

  @override
  State<DebugLogPage> createState() => _DebugLogPageState();
}

class _DebugLogPageState extends State<DebugLogPage> {
  bool _debugLog = false;
  bool _uploading = false;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _debugLog = persistentStateRepo.enableDebugLog;
  }

  Future<void> _toggleDebugLog(bool value) async {
    persistentStateRepo.setEnableDebugLog(value);
    setState(() {
      _debugLog = value;
    });
    await xController.restart();
    if (!value) {
      await unsetDebugLoggerProduction();
    } else {
      await setDebugLoggerProduction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? getAdaptiveAppBar(
              context, Text(AppLocalizations.of(context)!.debugLog))
          : null,
      body: isPkg
          ? Center(
              child: GestureDetector(
                  onTap: () {
                    count++;
                    if (count >= 10 && count < 20) {
                      snack('debug log enabled');
                      persistentStateRepo.setEnableDebugLog(true);
                      setDebugLoggerProduction();
                    } else if (count >= 20) {
                      snack('debug log disabled');
                      persistentStateRepo.setEnableDebugLog(false);
                      unsetDebugLoggerProduction();
                    }
                  },
                  child:
                      Text(AppLocalizations.of(context)!.debugLogNotAvailable)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.debugLog),
                      const Spacer(),
                      Switch(value: _debugLog, onChanged: _toggleDebugLog),
                    ],
                  ),
                  const Gap(5),
                  Text(AppLocalizations.of(context)!.debugLogDesc,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  const Gap(10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                          onPressed: () async {
                            final reson = await showStringForm(context,
                                title: AppLocalizations.of(context)!
                                    .describeTheProblem,
                                maxLines: 10);
                            setState(() {
                              _uploading = true;
                            });
                            logUploadService ??= LogUploadService(
                                flutterLogDir: await getFlutterLogDir(),
                                tunnelLogDir: await getTunnelLogDir(),
                                secret: logKey,
                                uploadUrl: isProduction()
                                    ? 'https://vproxybackend.5vnetwork.com:443/api/upload-logs'
                                    : 'http://127.0.0.1:11111/api/upload-logs');
                            try {
                              await logUploadService!.uploadDebugLog(
                                  reson ?? 'no reason provided');
                              snack('日志上传成功。谢谢您的反馈！');
                              // remove all debug log files
                              // final debugLogDir = await getDebugTunnelLogDir();
                              // await debugLogDir.delete(recursive: true);
                              // final flutterLogDir =
                              //     await getDebugFlutterLogDir();
                              // await flutterLogDir.delete(recursive: true);
                            } catch (e) {
                              snack('无法上传日志：$e');
                            } finally {
                              setState(() {
                                _uploading = false;
                              });
                            }
                          },
                          child: _uploading
                              ? smallCircularProgressIndicator
                              : Text(AppLocalizations.of(context)!.upload)),
                      if (!Platform.isIOS && !Platform.isMacOS)
                        OutlinedButton(
                            onPressed: () async {
                              late Directory? downloadsDir;
                              if (Platform.isAndroid) {
                                downloadsDir =
                                    Directory('/storage/emulated/0/Download/');
                              } else {
                                downloadsDir = await getDownloadsDirectory();
                              }
                              final debugLogDir = await getDebugTunnelLogDir();
                              final dstDir =
                                  join(downloadsDir!.path, "vx_debug_logs");
                              if (!Directory(dstDir).existsSync()) {
                                Directory(dstDir).createSync(recursive: true);
                              }
                              for (final file
                                  in await debugLogDir.list().toList()) {
                                if (file is File) {
                                  final fileName = basename(file.path);
                                  if (fileName.startsWith(".")) {
                                    continue;
                                  }
                                  await file.copy(join(dstDir, fileName));
                                }
                              }
                              rootScaffoldMessengerKey.currentState
                                  ?.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "开发者日志已保存至: $dstDir",
                                  ),
                                  duration: const Duration(seconds: 10),
                                ),
                              );
                              // remove all debug log files
                              await debugLogDir.delete(recursive: true);
                            },
                            child: Text(AppLocalizations.of(context)!
                                .saveToDownloadFolder)),
                      OutlinedButton(
                          onPressed: () async {
                            await _toggleDebugLog(false);
                            // remove all debug log files
                            final dir = await getDebugTunnelLogDir();
                            await dir.delete(recursive: true);
                            final flutterLogDir = await getDebugFlutterLogDir();
                            await flutterLogDir.delete(recursive: true);
                          },
                          child: Text(
                              AppLocalizations.of(context)!.deleteDebugLogs)),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
