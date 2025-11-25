import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the Supabase client instance.
///
/// Returns null if Supabase is not initialized (e.g., missing config).
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    // Supabase not initialized
    return null;
  }
});

/// Provides the current auth state as a stream.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return const Stream.empty();
  }
  return client.auth.onAuthStateChange;
});

/// Provides the current user (nullable).
final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client?.auth.currentUser;
});

/// Provides whether user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Provides whether Supabase is available/configured.
final isSupabaseAvailableProvider = Provider<bool>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client != null;
});
