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

// import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vx/auth/user.dart' as my;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// TODO: update the Web client ID with your own.
///
/// Web Client ID that you registered with Google Cloud.
const webClientId =
    '642537964996-q9d545nfbcj2p20n53esm925hmo2qce0.apps.googleusercontent.com';

/// TODO: update the iOS client ID with your own.
///
/// iOS Client ID that you registered with Google Cloud.
const iosClientId =
    '642537964996-qjhnfgpvsqgghnausmo5rbc04e57l4i5.apps.googleusercontent.com';
