part of 'home.dart';

class ProxySelectorHome extends StatelessWidget {
  const ProxySelectorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: AppLocalizations.of(context)!.selector,
      icon: Icons.filter_alt_outlined,
      child: const DefaultProxySelector(),
    );
  }
}
