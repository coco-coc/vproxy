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
