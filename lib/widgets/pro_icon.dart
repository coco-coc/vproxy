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
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/theme.dart';

const proIcon = Icon(Icons.stars_rounded, color: XBlue);
const proIconExtraSmall = Icon(Icons.stars_rounded, color: XBlue, size: 16);
const proIconSmall = Icon(Icons.stars_rounded, color: XBlue, size: 18);
const largeProIcon = Icon(Icons.stars_rounded, color: XBlue, size: 32);

class ActivatedIcon extends StatelessWidget {
  const ActivatedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(
        Icons.verified_user_rounded,
        color: XBlue,
      ),
      label: Text(AppLocalizations.of(context)!.activated,
          style: Theme.of(context).textTheme.bodySmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }
}
