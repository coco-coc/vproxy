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

abstract class AuthProvider {
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithMicrosoft();
  Future<void> signInWithEmailOtp(String email);
  Future<void> verifyEmailOtp(String email, String otp);
  Future<void> logOut();
  Stream<my.User?> get user;
  my.User? get currentUser;
  Future<void> refreshUser();
  Future<void> deleteAccount();
  Future<void> signInWithTest();
}

class SupabaseAuth extends AuthProvider {
  SupabaseAuth() {
    _userController = BehaviorSubject<my.User?>.seeded(
      currentUser,
    );
    supabase.auth.onAuthStateChange.forEach((event) {
      logger.d("authStateChange, current user: ${event.session?.user}");
      if (event.session != null) {
        _userController.add(_toUser(event.session!));
      } else {
        _userController.add(null);
      }
    });
  }

  late final BehaviorSubject<my.User?> _userController;

  @override
  Stream<my.User?> get user {
    return _userController.stream;
  }

  @override
  my.User? get currentUser {
    if (supabase.auth.currentSession == null) {
      return null;
    }
    return _toUser(supabase.auth.currentSession!);
  }

  // Helper function to decode JWT and extract claims
  Map<String, dynamic> _decodeJwt(String token) {
    try {
      // JWT has 3 parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token');
      }

      // Decode the payload (middle part)
      final payload = parts[1];

      // JWT uses base64Url encoding, we need to normalize it
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));

      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      logger.e('Error decoding JWT: $e');
      return {};
    }
  }

  // retrive user profile from supabase
  my.User _toUser(Session session) {
    final user = session.user;

    // Decode the access token to get custom claims
    final claims = _decodeJwt(session.accessToken);
    logger.d('JWT claims: $claims');

    // Extract the 'pro' claim from JWT
    final isPro = claims['pro'] as bool? ?? false;
    final proExpiredAt = claims['pro_expired_at'] as int?;
    return my.User(
      id: user.id,
      email: user.email!,
      pro: isPro,
      proExpiredAt: proExpiredAt != null
          ? DateTime.fromMillisecondsSinceEpoch(proExpiredAt * 1000)
          : null,
    );
  }

  @override
  Future<void> refreshUser() async {
    // Refresh the session to get updated JWT claims
    await supabase.auth.refreshSession();
    final session = supabase.auth.currentSession;
    if (session == null) {
      _userController.add(null);
      return;
    }
    _userController.add(_toUser(session));
  }

  /// Performs Apple sign in on iOS or macOS
  @override
  Future<AuthResponse> signInWithApple() async {
    final rawNonce = supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
          'Could not find ID Token from generated credential.');
    }
    return supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    if (Platform.isAndroid || Platform.isIOS) {
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

      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
          clientId: Platform.isIOS ? iosClientId : null,
          serverClientId: webClientId);
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      // final GoogleSignIn googleSignIn = GoogleSignIn(
      //   clientId: Platform.isIOS ? iosClientId : null,
      //   serverClientId: webClientId,
      // );
      // final googleUser = await googleSignIn.signIn();
      // final googleAuth = await googleUser!.authentication;
      // final accessToken = googleAuth.accessToken;
      // final idToken = googleAuth.idToken;
      // if (accessToken == null) {
      //   throw 'No Access Token found.';
      // }
      if (idToken == null) {
        throw 'No ID Token found.';
      }
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        // accessToken: accessToken,
      );
      return;
    }
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'vx://login-callback/',
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signInWithMicrosoft() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.azure,
      redirectTo: 'vx://login-callback/',
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signInWithEmailOtp(String email) async {
    await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'vx://login-callback/',
        shouldCreateUser: true);
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    await supabase.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.email,
    );
  }

  @override
  Future<void> signInWithTest() async {
    await supabase.auth.signInWithPassword(
      email: 'test@example.com',
      password: '123456789',
    );
  }

  @override
  Future<void> logOut() async {
    try {
      await Future.wait([
        // _firebaseAuth.signOut(),
        // _googleSignIn.signOut(),
        supabase.auth.signOut(),
      ]);
    } catch (_) {
      throw 'Log out failed';
    }
  }

  @override
  Future<void> deleteAccount() async {
    if (currentUser == null) {
      throw 'No Current User';
    }
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) {
      throw 'No Token';
    }
    await supabase.functions.invoke('delete-account', headers: {
      'Authorization': 'Bearer $token',
    });
    supabase.auth.signOut();
  }
}
