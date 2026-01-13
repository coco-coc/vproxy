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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:grpc/grpc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tm/protos/app/api/api.pb.dart';
import 'package:vx/common/net.dart';
import 'package:vx/data/database.dart';
import 'package:vx/theme.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/utils/xapi_client.dart';

class ServerStatus extends StatefulWidget {
  const ServerStatus({
    super.key,
    required this.server,
  });
  final SshServer server;

  @override
  State<ServerStatus> createState() => _ServerStatusState();
}

class _ServerStatusState extends State<ServerStatus> {
  ResponseStream<MonitorServerResponse>? stream;
  bool _connecting = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    stream?.cancel();
    stream = null;
    super.dispose();
  }

  void _connect() {
    context.read<XApiClient>().monitorServer(widget.server).then((stream) {
      setState(() {
        this.stream = stream;
        _connecting = false;
        _error = null;
      });
    }).catchError((e) {
      setState(() {
        _connecting = false;
        _error = e.toString();
      });
    });
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: SizedBox(
                          width: 300,
                          height: 200,
                          child: Text(_error ?? ''),
                        ),
                      ));
            },
            child: Text(
              AppLocalizations.of(context)!.failedConnectServer,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
          TextButton(
              onPressed: () => _connect(),
              child: Text(AppLocalizations.of(context)!.retry)),
        ],
      ),
    );
  }

  Widget _loadingWidget() {
    return SizedBox(
      height: 52,
      child: Center(
        child: Text(AppLocalizations.of(context)!.connecting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_connecting) {
      return SizedBox(
        height: 52,
        child: Center(
          child: Text(AppLocalizations.of(context)!.connecting),
        ),
      );
    }
    if (_error != null) {
      return _errorWidget();
    }

    return StreamBuilder(
        stream: stream,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return _errorWidget();
          }
          if (snapshot.data == null) {
            return _loadingWidget();
          }
          final s = snapshot.data as MonitorServerResponse;
          late double memPercent;
          if (s.totalMemory.isZero) {
            return const SizedBox.shrink();
          } else {
            memPercent = (s.usedMemory.toInt() / s.totalMemory.toInt()) * 100;
          }
          final memPercentRound = memPercent.round();
          if (memPercent.isNaN) {
            memPercent = 0;
          }

          late double diskPercent;
          if (s.totalDisk == 0) {
            diskPercent = 0;
          } else {
            diskPercent = (s.usedDisk / s.totalDisk) * 100;
          }
          final diskPercentRound = diskPercent.round();
          if (diskPercent.isNaN) {
            diskPercent = 0;
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularPercentIndicator(
                radius: 24,
                startAngle: 180,
                lineWidth: 7.0,
                footer: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    'CPU',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                center: Text('${s.cpu}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        )),
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                percent: s.cpu / 100,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: valueToColor(s.cpu),
              ),
              const Gap(15),
              CircularPercentIndicator(
                radius: 24,
                lineWidth: 7.0,
                startAngle: 180,
                footer: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    AppLocalizations.of(context)!.memory,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                center: Text('$memPercentRound%',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                percent: memPercent / 100,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: valueToColor(memPercentRound),
              ),
              const Gap(15),
              CircularPercentIndicator(
                radius: 25,
                lineWidth: 7.0,
                startAngle: 180,
                footer: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    AppLocalizations.of(context)!.storage,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                center: Text('$diskPercentRound%',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                percent: diskPercent / 100,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: valueToColor(diskPercentRound),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  children: [
                    const Gap(2),
                    Row(
                      children: [
                        const Icon(
                          Icons.north,
                          size: 14,
                          color: XBlue,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('${bytesToReadable(s.netOutSpeed)}/s',
                                softWrap: true,
                                style: Theme.of(context).textTheme.labelSmall),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        const Icon(
                          Icons.south,
                          size: 14,
                          color: XPink,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('${bytesToReadable(s.netInSpeed)}/s',
                                softWrap: true,
                                style: Theme.of(context).textTheme.labelSmall),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }
}

Color valueToColor(int value) {
  if (value < 50) {
    return Colors.green;
  } else if (value < 80) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
