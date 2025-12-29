import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:protobuf/protobuf.dart';
import 'package:provider/provider.dart';
import 'package:tm/protos/common/log/log.pb.dart';
import 'package:tm/protos/google/protobuf/any.pbserver.dart';
import 'package:tm/protos/protos/inbound.pb.dart';
import 'package:tm/protos/protos/logger.pb.dart';
import 'package:tm/protos/protos/proxy/hysteria.pb.dart';
import 'package:tm/protos/protos/proxy/shadowsocks.pb.dart';
import 'package:tm/protos/protos/proxy/socks.pb.dart';
import 'package:tm/protos/protos/proxy/trojan.pb.dart';
import 'package:tm/protos/protos/proxy/vmess.pb.dart';
import 'package:tm/protos/protos/server/server.pb.dart';
import 'package:tm/protos/transport/protocols/grpc/config.pb.dart';
import 'package:tm/protos/transport/protocols/http/config.pb.dart';
import 'package:tm/protos/transport/protocols/httpupgrade/config.pb.dart';
import 'package:tm/protos/transport/protocols/websocket/config.pb.dart';
import 'package:vx/app/routing/mode_widget.dart';
import 'package:vx/app/server/vx_bloc.dart';
import 'package:vx/common/config.dart';
import 'package:vx/common/net.dart';
import 'package:vx/data/database.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/utils/xapi_client.dart';
import 'package:vx/widgets/add_button.dart';
import 'package:vx/widgets/clickable_card.dart';
import 'package:vx/widgets/delete_menu_anchor.dart';
import 'package:vx/widgets/divider.dart';
import 'package:vx/widgets/dropdown_filter_chip.dart';
import 'package:vx/widgets/form_dialog.dart';
import 'package:vx/widgets/outbound_handler_form/outbound_handler_form.dart';
import 'package:vx/widgets/text_divider.dart';

part 'vx_config_inbound.dart';
part 'vx_config_routing.dart';

class VXConfig extends StatelessWidget {
  const VXConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VXBloc, VXState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        switch (state) {
          case VXInstalledState():
            return const _Config();
          case VXLoadingState():
            return const Center(
              child: CircularProgressIndicator(),
            );
          case VXNotInstalledState():
            return Center(
              child: Text(AppLocalizations.of(context)!.installVXCoreFirst),
            );
          case VXErrorState():
            return Center(
              child: Text(state.error),
            );
        }
      },
    );
  }
}

enum ServerDetailSegment { inbounds, routing, geo, outbounds, others }

class _Config extends StatelessWidget {
  const _Config({super.key});
  @override
  Widget build(BuildContext context) {
    // final config = context.select((VproxyBloc bloc) =>
    //     bloc.state is VproxyInstalledState
    //         ? (bloc.state as VproxyInstalledState).config
    //         : null);
    // if (config == null) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }
    // print('object');
    return BlocBuilder<VXBloc, VXState>(buildWhen: (previous, current) {
      if (previous is VXInstalledState && current is VXInstalledState) {
        print(previous.config != current.config);
        return previous.config != current.config;
      }
      return false;
    }, builder: (context, state) {
      if (state is! VXInstalledState || state.config == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return _Inbounds(config: state.config!);
      return DefaultTabController(
        length: 5,
        child: Column(
          children: [
            TabBar(tabs: [
              Tab(text: AppLocalizations.of(context)!.inbound),
              Tab(text: AppLocalizations.of(context)!.routing),
              Tab(text: AppLocalizations.of(context)!.set),
              Tab(text: AppLocalizations.of(context)!.outboundMode),
              Tab(text: AppLocalizations.of(context)!.others),
            ]),
            const Gap(10),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBarView(children: [
                _Inbounds(config: state.config!),
                _Routing(config: state.config!),
                const _Geo(),
                const _Outbounds(),
                const _Others(),
              ]),
            )),
          ],
        ),
      );
    });
  }
}

class _Geo extends StatelessWidget {
  const _Geo({super.key});
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Outbounds extends StatelessWidget {
  const _Outbounds({super.key});
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Others extends StatelessWidget {
  const _Others({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LogLevel(),
      ],
    );
  }
}

class _LogLevel extends StatelessWidget {
  const _LogLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final logLevel = context.select((VXBloc bloc) {
      if (bloc.state is VXInstalledState) {
        final state = bloc.state as VXInstalledState;
        if (state.config == null) {
          return null;
        }
        if (state.config!.hasLog()) {
          return state.config!.log.logLevel;
        }
        return Level.DISABLED;
      }
      return null;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.logLevel,
            style: Theme.of(context).textTheme.titleSmall),
        Gap(5),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: Level.values
              .map((e) => ChoiceChip(
                    label: Text(e.name),
                    selected: logLevel == e,
                    onSelected: (selected) {
                      context.read<VXBloc>().add(VXSetLogLevelEvent(e));
                    },
                  ))
              .toList(),
        )
      ],
    );
  }
}
