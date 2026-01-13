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

extension BreakpointUtils on BoxConstraints {
  bool get isCompact => maxWidth < 600;
  bool get isMedium => maxWidth >= 600 && maxWidth < 840;
  bool get isExpanded => maxWidth >= 840 && maxWidth < 1200;
  bool get isLarge => maxWidth >= 1200 && maxWidth < 1600;
  bool get isSuperLarge => maxWidth >= 1600;
  // Layout get layout {
  //   if (isCompact) {
  //     return Layout.compact;
  //   }
  // }
}

extension LayoutUtils on Size {
  bool get isCompact => width < 600;
  bool get isMedium => width >= 600 && width < 840;
  bool get compactOrMedium => width < 840;
  bool get isExpanded => width >= 840 && width < 1200;
  bool get isLarge => width >= 1200 && width < 1600;
  bool get isSuperLarge => width >= 1600;
}

enum Layout { compact, medium, expanded, large, superLarge }
