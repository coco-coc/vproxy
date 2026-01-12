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
import 'package:vx/common/common.dart';

enum Layout { compact, medium, expanded, superExpanded }

class MyLayout {
  double? width;
  double? height;
  Layout? layout;

  AppLifecycleState appstate = AppLifecycleState.resumed;
  bool get isDesktop => width == null ? false : width! >= 1200;
  bool get isCompact => width == null ? true : width! < 600;
  bool get compactOrMedium => width == null ? true : width! < 840;
  
  bool fullScreen() {
    if (desktopPlatforms && isCompact) {
      return true;
    } else if (!desktopPlatforms && compactOrMedium) {
      return true;
    } else {
      return false;
    }
  }

  void setFields(double width, double height) {
    // if (appstate == AppLifecycleState.paused) return;
    this.width = width;
    this.height = height;
  }
}
