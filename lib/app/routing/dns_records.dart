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

part of 'dns.dart';

class _DnsRecords extends StatefulWidget {
  const _DnsRecords({super.key});

  @override
  State<_DnsRecords> createState() => __DnsRecordsState();
}

class __DnsRecordsState extends State<_DnsRecords>
    with AutomaticKeepAliveClientMixin<_DnsRecords> {
  final width = 300;
  late DnsRepo _dnsRepo;
  StreamSubscription? _dnsRecordsSubscription;
  List<DnsRecord> _records = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dnsRepo = Provider.of<DnsRepo>(context, listen: true);
    _dnsRecordsSubscription?.cancel();
    _dnsRecordsSubscription = _dnsRepo.getDnsRecordsStream().listen((value) {
      setState(() {
        _records = value;
      });
    });
  }

  @override
  void dispose() {
    _dnsRecordsSubscription?.cancel();
    super.dispose();
  }

  void _onAdd() async {
    final k = GlobalKey();
    final record = await showMyAdaptiveDialog<Record?>(
      context,
      _DnsRecordForm(key: k),
      title: AppLocalizations.of(context)!.addDnsRecord,
      onSave: (BuildContext context) {
        final formData = (k.currentState as FormDataGetter).formData;
        if (formData != null) {
          context.pop(formData);
        }
      },
    );
    if (record != null) {
      await _dnsRepo.addDnsRecord(record);
    }
  }

  void _onEdit(int index) async {
    final k = GlobalKey();
    final record = await showMyAdaptiveDialog<Record?>(
      context,
      _DnsRecordForm(key: k, record: _records[index].dnsRecord),
      title: AppLocalizations.of(context)!.edit,
      onSave: (BuildContext context) {
        final formData = (k.currentState as FormDataGetter).formData;
        if (formData != null) {
          context.pop(formData);
        }
      },
    );
    if (record != null) {
      await _dnsRepo.updateDnsRecord(_records[index], record);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth ~/ width;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.tonal(
              onPressed: _onAdd,
              child: Text(AppLocalizations.of(context)!.addDnsRecord),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _records.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.empty,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : MasonryGridView.count(
                      padding: const EdgeInsets.only(bottom: 70),
                      crossAxisCount: count,
                      itemCount: _records.length,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              _onEdit(index);
                            },
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (record.dnsRecord.domain.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.domain,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 5),
                                            Chip(
                                              shape: chipBorderRadius,
                                              backgroundColor: Theme.of(
                                                context,
                                              ).colorScheme.surfaceContainerLow,
                                              label: Text(
                                                record.dnsRecord.domain,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      if (record.dnsRecord.ip.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'IP',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 5),
                                            Wrap(
                                              runSpacing: 5,
                                              spacing: 5,
                                              children: record.dnsRecord.ip
                                                  .map(
                                                    (e) => Chip(
                                                      shape: chipBorderRadius,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surfaceContainerLow,
                                                      label: Text(e),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      if (record
                                          .dnsRecord
                                          .proxiedDomain
                                          .isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Proxied Domain',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 5),
                                            Chip(
                                              shape: chipBorderRadius,
                                              backgroundColor: Theme.of(
                                                context,
                                              ).colorScheme.surfaceContainerLow,
                                              label: Text(
                                                record.dnsRecord.proxiedDomain,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: IconButton(
                                    onPressed: () async {
                                      await _dnsRepo.removeDnsRecord(record);
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _DnsRecordForm extends StatefulWidget {
  const _DnsRecordForm({super.key, this.record});
  final Record? record;
  @override
  State<_DnsRecordForm> createState() => __DnsRecordFormState();
}

class __DnsRecordFormState extends State<_DnsRecordForm> with FormDataGetter {
  final _formKey = GlobalKey<FormState>();
  final _domainController = TextEditingController();
  final _ipController = TextEditingController();
  final _proxiedDomainController = TextEditingController();

  @override
  Object? get formData {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return null;
    }
    return Record(
      domain: _domainController.text,
      ip: _ipController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      proxiedDomain: _proxiedDomainController.text,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _domainController.text = widget.record!.domain;
      _ipController.text = widget.record!.ip.join(', ');
      _proxiedDomainController.text = widget.record!.proxiedDomain;
    }
  }

  @override
  void dispose() {
    _domainController.dispose();
    _ipController.dispose();
    _proxiedDomainController.dispose();
    super.dispose();
  }

  String? _validateIp(String? value) {
    if (value == null || value.isEmpty) {
      return null; // IP is optional
    }
    final ips = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    for (var ip in ips) {
      if (!isValidIp(ip)) {
        return AppLocalizations.of(context)!.invalidIp;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _domainController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.empty;
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              labelText: AppLocalizations.of(context)!.domain,
              hintText: 'example.com',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _ipController,
            validator: _validateIp,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              labelText: 'IP Addresses',
              hintText: '1.1.1.1,2400:3200::1',
              helperText: 'A/AAAA',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _proxiedDomainController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              labelText: 'Proxied Domain',
              hintText: 'proxied.example.com',
              helperText: 'CNAME',
            ),
          ),
        ],
      ),
    );
  }
}
