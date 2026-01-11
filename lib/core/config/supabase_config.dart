class SupabaseConfig {
  static const String supabaseUrl = 'https://vvavgomyvhqkbfvbsusw.supabase.co';

  // Anon key is safe to embed - it's public and RLS protects data
  static const String supabaseAnonKey = '**********************************************';

  static const String communeFunctionUrl = '$supabaseUrl/functions/v1/commune';

  // Rate limiting
  static const int maxFreeSessions = 3;

  // Prevent instantiation
  SupabaseConfig._();
}
