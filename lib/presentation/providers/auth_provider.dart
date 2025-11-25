import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/auth_service.dart';
import 'supabase_provider.dart';

/// Provides the AuthService instance.
final authServiceProvider = Provider<AuthService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return AuthService(client);
});

/// Manages auth initialization state.
///
/// On first launch, this will sign in anonymously.
/// Returns true when auth is ready, false if Supabase is not available.
final authInitializationProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);

  // If Supabase is not configured, skip auth
  if (authService == null) {
    debugPrint('AuthInit: Supabase not configured, skipping auth');
    return false;
  }

  // If already authenticated, we're good
  if (authService.isAuthenticated) {
    debugPrint('AuthInit: Already authenticated as ${authService.currentUser?.id}');
    return true;
  }

  // Sign in anonymously
  try {
    await authService.signInAnonymously();
    return true;
  } catch (e) {
    debugPrint('AuthInit: Failed to sign in anonymously: $e');
    // Don't throw - app can still work offline
    return false;
  }
});
