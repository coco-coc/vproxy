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

part of 'routing_page.dart';

class IPWidget extends StatefulWidget {
  const IPWidget(
      {super.key,
      required this.ipSetName,
      this.showLabel = true,
      this.addButtonInWrap = false});

  final String ipSetName;
  final bool showLabel;
  final bool addButtonInWrap;
  @override
  State<IPWidget> createState() => _IPWidgetState();
}

class _IPWidgetState extends State<IPWidget> {
  StreamSubscription? _geoIPSubscription;
  List<Cidr> _cidrs = [];
  late SetRepo setRepo;
  @override
  void initState() {
    super.initState();
  }

  void _subscribe() {
    _geoIPSubscription = setRepo
        .getCidrsStream(
      widget.ipSetName,
    )
        .listen((q) {
      setState(() {
        _cidrs = q;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setRepo = Provider.of<SetRepo>(context, listen: true);
    _geoIPSubscription?.cancel();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant IPWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ipSetName != widget.ipSetName) {
      _geoIPSubscription?.cancel();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _geoIPSubscription?.cancel();
    super.dispose();
  }

  void _onAddIP() async {
    final result = await showDialog(
        barrierDismissible: desktopPlatforms ? true : false,
        context: context,
        builder: (context) => const AddDialog(domain: false));
    if (result != null && result is List<CIDR>) {
      await setRepo.bulkAddCidr(widget.ipSetName, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // return SizedBox();
    final wrap = Wrap(
      runSpacing: 10,
      spacing: 10,
      children: [
        ..._cidrs.map((cidr) {
          return WrapChild(
            shape: chipBorderRadius,
            text: cidrToString(cidr.cidr),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            onDelete: () => setRepo.removeCidr(cidr),
          );
        }),
        if (widget.addButtonInWrap)
          IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(0),
              onPressed: _onAddIP,
              icon: const Icon(Icons.add_rounded, size: 18)),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.addButtonInWrap)
          Row(
            children: [
              if (widget.showLabel)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Chip(
                    side: const BorderSide(color: Colors.transparent),
                    shape: chipBorderRadius,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    label: Text('IP',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(0),
                  onPressed: _onAddIP,
                  icon: const Icon(Icons.add_rounded)),
              const Gap(10),
            ],
          ),
        const Gap(10),
        widget.addButtonInWrap
            ? wrap
            : Expanded(
                child: SingleChildScrollView(
                  child: wrap,
                ),
              ),
        // Expanded(
        //   child: ListView.builder(
        //     itemCount: _cidrs.length,
        //     itemExtent: 32,
        //     itemBuilder: (context, index) {
        //       final cidr = _cidrs[index];
        //       String displayString = InternetAddress.fromRawAddress(
        //               Uint8List.fromList(cidr.cidr.ip))
        //           .address;
        //       if (cidr.cidr.prefix != 32 && cidr.cidr.prefix != 128) {
        //         displayString += '/${cidr.cidr.prefix}';
        //       }
        //       return SwipeActionCell(
        //         key: ValueKey(index),
        //         trailingActions: [
        //           SwipeAction(
        //             color: Theme.of(context).colorScheme.error,
        //             widthSpace: 50,
        //             icon: Icon(
        //               Icons.delete_outlined,
        //               color: Theme.of(context).colorScheme.onError,
        //             ),
        //             onTap: (CompletionHandler handler) async {},
        //           )
        //         ],
        //         child: Container(
        //           child: Align(
        //             alignment: Alignment.centerLeft,
        //             child: Text(displayString,
        //                 style: Theme.of(context).textTheme.bodyMedium!),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // )
      ],
    );
  }
}

String cidrToString(CIDR cidr) {
  String displayString =
      InternetAddress.fromRawAddress(Uint8List.fromList(cidr.ip)).address;
  if (cidr.prefix != 32 && cidr.prefix != 128) {
    displayString += '/${cidr.prefix}';
  }
  return displayString;
}
