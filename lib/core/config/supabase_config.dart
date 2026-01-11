class SupabaseConfig {
  static const String supabaseUrl = 'https://vvavgomyvhqkbfvbsusw.supabase.co';

  static String get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (key.isEmpty) {
      throw StateError(
          'SUPABASE_ANON_KEY is not set. Run with --dart-define=SUPABASE_ANON_KEY=...');
    }
    return key;
  }

  static const String communeFunctionUrl = '$supabaseUrl/functions/v1/commune';

  // Rate limiting
  static const int maxFreeSessions = 3;

  // Prevent instantiation
  SupabaseConfig._();
}
