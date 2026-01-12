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

part of 'outbound_handler_form.dart';

/// Collect a header config
class _TransportHeaderSelector extends StatefulWidget {
  const _TransportHeaderSelector(
      {required this.setter});

  final void Function(Any) setter;

  @override
  State<_TransportHeaderSelector> createState() =>
      _TransportHeaderSelectorState();
}

class _TransportHeaderSelectorState extends State<_TransportHeaderSelector> {
  TransportHeaderLabel? _selected;
  late final DropdownMenu<TransportHeaderLabel> _dropdownMenu;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dropdownMenu = DropdownMenu<TransportHeaderLabel>(
      requestFocusOnTap: false,
      initialSelection: _selected,
      label: Text(AppLocalizations.of(context)!.protocol),
      onSelected: (TransportHeaderLabel? l) {
        setState(() {
          _selected = l;
        });
      },
      dropdownMenuEntries: TransportHeaderLabel.values
          .map<DropdownMenuEntry<TransportHeaderLabel>>(
              (TransportHeaderLabel p) {
        return DropdownMenuEntry<TransportHeaderLabel>(
          label: p.label,
          value: p,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_dropdownMenu]);
  }
}

/// collect http header config
class _HttpHeaderConfig extends StatefulWidget {
  const _HttpHeaderConfig();

  @override
  State<_HttpHeaderConfig> createState() => _HttpHeaderConfigState();
}

class _HttpHeaderConfigState extends State<_HttpHeaderConfig> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(children: []);
  }
}

class ConfigForm extends StatefulWidget {
  final Function(http_header.Config) onConfigChanged;

  const ConfigForm({super.key, required this.onConfigChanged});

  @override
  _ConfigFormState createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  final _config = http_header.Config();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'HTTP Version'),
          onSaved: (value) {
            _config.request.version.value = value ?? '';
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'HTTP Method'),
          onSaved: (value) {
            _config.request.method.value = value ?? '';
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'URI'),
          onSaved: (value) {
            if (value != null && value.isNotEmpty) {
              _config.request.uri.add(value);
            }
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'HTTP Version'),
          onSaved: (value) {
            _config.response.version.value = value ?? '';
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Status Code'),
          onSaved: (value) {
            _config.response.status.code = value ?? '';
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Status Reason'),
          onSaved: (value) {
            _config.response.status.reason = value ?? '';
          },
        ),
      ],
    );
  }
}
