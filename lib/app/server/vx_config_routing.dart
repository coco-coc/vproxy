part of 'vx_config.dart';

class _Routing extends StatelessWidget {
  const _Routing({super.key, required this.config});
  final ServerConfig config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: UnmodifiableRouteConfig(routerConfig: config.router),
    );
  }
}
