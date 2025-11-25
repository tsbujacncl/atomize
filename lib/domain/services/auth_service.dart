import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for handling Supabase authentication.
///
/// Provides anonymous authentication by default, with the option
/// to upgrade to email-based authentication later.
class AuthService {
  final SupabaseClient _client;
  final FlutterSecureStorage _secureStorage;

  static const _deviceIdKey = 'atomize_device_id';

  AuthService(this._client)
      : _secureStorage = const FlutterSecureStorage();

  /// Current authenticated user (nullable).
  User? get currentUser => _client.auth.currentUser;

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign in anonymously - called on first app launch.
  ///
  /// Creates a new anonymous account that can later be upgraded
  /// to a full account with email/password.
  Future<AuthResponse> signInAnonymously() async {
    try {
      debugPrint('AuthService: Signing in anonymously...');
      final response = await _client.auth.signInAnonymously();

      if (response.user != null) {
        debugPrint('AuthService: Anonymous sign-in successful: ${response.user!.id}');
      }

      return response;
    } catch (e) {
      debugPrint('AuthService: Anonymous sign-in failed: $e');
      rethrow;
    }
  }

  /// Link anonymous account to email (upgrade path).
  ///
  /// Call this when user wants to create a "real" account
  /// to preserve their data across devices.
  Future<UserResponse> linkEmailToAnonymous(String email, String password) async {
    return await _client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
      ),
    );
  }

  /// Sign in with email/password.
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email/password.
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get or create a unique device ID.
  ///
  /// Used to track which device created/modified data.
  Future<String> getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  /// Check if this is an anonymous user (can be upgraded).
  /// Anonymous users have no email and isAnonymous flag set.
  bool get isAnonymous {
    final user = currentUser;
    if (user == null) return true;
    // Check both isAnonymous flag and absence of email
    return user.isAnonymous == true || (user.email == null || user.email!.isEmpty);
  }

  /// Get user's email if available.
  String? get userEmail => currentUser?.email;

  /// Sign in with Apple.
  ///
  /// Uses native Apple Sign-In and exchanges the credential with Supabase.
  Future<AuthResponse> signInWithApple() async {
    try {
      debugPrint('AuthService: Starting Apple Sign-In...');

      // Generate a random nonce for security
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Request Apple credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Apple Sign-In failed: No identity token received');
      }

      // Sign in to Supabase with the Apple ID token
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      debugPrint('AuthService: Apple Sign-In successful: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('AuthService: Apple Sign-In failed: $e');
      rethrow;
    }
  }

  /// Sign in with Google.
  ///
  /// Uses Google Sign-In SDK and exchanges the credential with Supabase.
  /// Note: Requires setup in Google Cloud Console and Supabase dashboard.
  Future<AuthResponse> signInWithGoogle() async {
    try {
      debugPrint('AuthService: Starting Google Sign-In...');

      // Create GoogleSignIn instance
      // Note: For iOS, add the iOS client ID to Info.plist
      // For web, configure in index.html
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Trigger sign-in flow
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      // Get authentication tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google Sign-In failed: No ID token received');
      }

      // Sign in to Supabase with the Google tokens
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('AuthService: Google Sign-In successful: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('AuthService: Google Sign-In failed: $e');
      rethrow;
    }
  }

  /// Generate a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Delete user account and all associated data.
  Future<void> deleteAccount() async {
    // Note: This requires a Supabase Edge Function or RPC to delete user data
    // For now, just sign out
    await signOut();
  }

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
