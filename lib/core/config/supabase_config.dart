import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration for Supabase connection.
///
/// Credentials are loaded from .env file which is gitignored.
class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Validates that all required environment variables are set.
  static bool get isConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty;

  /// Debug mode - enable Supabase logging.
  static const bool enableDebugLogs = true;
}
