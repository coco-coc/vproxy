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

/// A TextFormField that runs validator onChange
class VTextFormField extends StatefulWidget {
  const VTextFormField({
    super.key,
    required this.validator,
    required this.onChanged,
    required this.decoration,
    this.controller,
  });

  final String? Function(String?) validator;
  final void Function(String?) onChanged;
  final InputDecoration decoration;
  final TextEditingController? controller;
  @override
  State<VTextFormField> createState() => _VTextFormFieldState();
}

class _VTextFormFieldState extends State<VTextFormField> {
  String? _errorText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: widget.decoration.copyWith(errorText: _errorText),
      onChanged: (value) {
        widget.onChanged(value);
        final errorText = widget.validator(value);
        if (errorText != null) {
          setState(() {
            _errorText = errorText;
          });
        }
      },
    );
  }
}
