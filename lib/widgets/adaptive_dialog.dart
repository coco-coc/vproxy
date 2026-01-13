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
import 'package:provider/provider.dart';
import 'package:vx/app/layout_provider.dart';

void showAdaptiveDialog(BuildContext context, Widget child) {
  if (context.read<MyLayout>().isCompact) {
    showModalBottomSheet(
        useRootNavigator: true, context: context, builder: (context) => child);
  } else {
    showDialog(context: context, builder: (context) => child);
  }
}
