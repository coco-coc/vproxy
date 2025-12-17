part of 'routing_page.dart';

class AtomicDomainSetWidget extends StatefulWidget {
  const AtomicDomainSetWidget(
      {super.key,
      required this.domainSetName,
      this.addButtonInWrap = false,
      this.showLabel = true});
  final String domainSetName;
  final bool addButtonInWrap;
  final bool showLabel;
  @override
  State<AtomicDomainSetWidget> createState() => _AtomicDomainSetWidgetState();
}

class _AtomicDomainSetWidgetState extends State<AtomicDomainSetWidget> {
  StreamSubscription? _geoDomainSubscription;
  List<GeoDomain> _geoDomains = [];
  late SetRepo domainRepo;

  @override
  void initState() {
    super.initState();
  }

  void _subscribe() {
    _geoDomainSubscription =
        domainRepo.getGeoDomainsStream(widget.domainSetName).listen((q) {
      setState(() {
        _geoDomains = q;
      });
    });
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies ${widget.domainSetName}');
    super.didChangeDependencies();
    domainRepo = Provider.of<SetRepo>(context, listen: true);
    _geoDomainSubscription?.cancel();
    _subscribe();
  }

  @override
  void dispose() {
    _geoDomainSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AtomicDomainSetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget ${oldWidget.domainSetName} ${widget.domainSetName}');
    if (oldWidget.domainSetName != widget.domainSetName) {
      _geoDomainSubscription?.cancel();
      _subscribe();
    }
  }

  void _onAddDomain() async {
    final result = await showDialog(
        barrierDismissible: desktopPlatforms ? true : false,
        context: context,
        builder: (context) => const AddDialog(domain: true));
    if (result != null && result is Domain) {
      await domainRepo.addGeoDomain(widget.domainSetName, result);
      xController.addGeoDomain(widget.domainSetName, result);
    } else if (result != null && result is PbList<Domain>) {
      await domainRepo.bulkAddGeoDomain(widget.domainSetName, result);
    }
  }

  void _onPickFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result != null) {
      try {
        final response = await xApiClient
            .parseClashRuleFile(result.files.first.bytes!.toList());
        await domainRepo.bulkAddGeoDomain(
            widget.domainSetName, response.domains);
      } catch (e) {
        snack(e.toString());
      }
    }
  }

  void _onDeleteDomain(GeoDomain domain) {
    domainRepo.removeGeoDomain(domain);
    xController.removeGeoDomain(widget.domainSetName, domain.geoDomain);
  }

  List<Widget> _buildWrapChildrenForDomains(BuildContext context) {
    final children = <Widget>[];
    children.add(WrapChild(
      shape: chipBorderRadius,
      text: AppLocalizations.of(context)!.keyword,
      backgroundColor: pinkColorTheme.secondaryContainer,
      foregroundColor: pinkColorTheme.onSecondaryContainer,
    ));
    children.addAll(_geoDomains
        .where((domain) => domain.geoDomain.type == Domain_Type.Plain)
        .map((domain) => WrapChild(
              shape: chipBorderRadius,
              text: domain.geoDomain.value,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              onDelete: () => _onDeleteDomain(domain),
            )));

    children.add(WrapChild(
      shape: chipBorderRadius,
      text: AppLocalizations.of(context)!.rootDomain,
      backgroundColor: greenColorTheme.secondaryContainer,
      foregroundColor: greenColorTheme.onSecondaryContainer,
    ));
    children.addAll(_geoDomains
        .where((domain) => domain.geoDomain.type == Domain_Type.RootDomain)
        .map((domain) => WrapChild(
              shape: chipBorderRadius,
              text: domain.geoDomain.value,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              onDelete: () => _onDeleteDomain(domain),
            )));
    children.add(WrapChild(
      shape: chipBorderRadius,
      text: AppLocalizations.of(context)!.exact,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
    ));
    children.addAll(_geoDomains
        .where((domain) => domain.geoDomain.type == Domain_Type.Full)
        .map((domain) => WrapChild(
              shape: chipBorderRadius,
              text: domain.geoDomain.value,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              onDelete: () => _onDeleteDomain(domain),
            )));
    children.add(WrapChild(
      shape: chipBorderRadius,
      text: AppLocalizations.of(context)!.regularExpression,
      backgroundColor: purpleColorTheme.secondaryContainer,
      foregroundColor: purpleColorTheme.onSecondaryContainer,
    ));
    children.addAll(_geoDomains
        .where((domain) => domain.geoDomain.type == Domain_Type.Regex)
        .map((domain) => WrapChild(
              shape: chipBorderRadius,
              text: domain.geoDomain.value,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              onDelete: () => _onDeleteDomain(domain),
            )));

    return children;
  }

  @override
  Widget build(BuildContext context) {
    final addButton = MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: _onAddDomain,
          leadingIcon: const Icon(Icons.edit_rounded),
          child: Text(AppLocalizations.of(context)!.mannual),
        ),
        MenuItemButton(
          onPressed: _onPickFromFile,
          leadingIcon: const Icon(Icons.folder),
          child: Text(AppLocalizations.of(context)!.selectFromFile),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(0),
            onPressed: () => controller.open(),
            icon: const Icon(Icons.add_rounded));
      },
    );

    return LayoutBuilder(builder: (ctx, c) {
      final header = widget.addButtonInWrap
          ? const SizedBox.shrink()
          : Row(
              children: [
                if (widget.showLabel)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Chip(
                      side: const BorderSide(color: Colors.transparent),
                      shape: chipBorderRadius,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      label: Text(AppLocalizations.of(context)!.domain,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.w500)),
                    ),
                  ),
                addButton,
                const Gap(10),
              ],
            );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const Gap(10),
          Expanded(
            child:
                // c.isCompact
                // ? CustomScrollView(slivers: [
                //     SliverToBoxAdapter(
                //       child: Wrap(
                //         runSpacing: 10,
                //         spacing: 10,
                //         children: _buildWrapChildren(context, true),
                //       ),
                //     ),
                //     SliverToBoxAdapter(
                //       child: SizedBox(
                //         height: 10,
                //       ),
                //     ),
                //     SliverFixedExtentList(
                //       itemExtent: 60,
                //       delegate: SliverChildBuilderDelegate(
                //         (ctx, index) {
                //           final domain = _fullAndRegexDomains[index];
                //           return ListTile(
                //             contentPadding:
                //                 const EdgeInsets.only(left: 5, right: 5),
                //             title: Text(domain.geoDomain.value),
                //             subtitle:
                //                 Text(domain.geoDomain.type.localName(context)),
                //             visualDensity: VisualDensity.compact,
                //             trailing: IconButton(
                //               onPressed: () {
                //                 (database.delete(database.geoDomains)
                //                       ..where((t) => t.id.equals(domain.id)))
                //                     .go();
                //               },
                //               icon: const Icon(Icons.delete_outline),
                //             ),
                //           );
                //         },
                //         childCount: _fullAndRegexDomains.length,
                //       ),
                //     )
                //   ])
                // :
                SingleChildScrollView(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                spacing: 10,
                children: [
                  ..._buildWrapChildrenForDomains(context),
                  if (widget.addButtonInWrap) addButton,
                ],
              ),
            ),
          )
        ],
      );
    });
  }
}

extension Domain_TypeExtension on Domain_Type {
  String localName(BuildContext context) {
    switch (this) {
      case Domain_Type.Plain:
        return AppLocalizations.of(context)!.keyword;
      case Domain_Type.RootDomain:
        return AppLocalizations.of(context)!.rootDomain;
      case Domain_Type.Full:
        return AppLocalizations.of(context)!.exact;
      case Domain_Type.Regex:
        return AppLocalizations.of(context)!.regularExpression;
      default:
        return '';
    }
  }
}
