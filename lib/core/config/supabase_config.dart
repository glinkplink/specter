class SupabaseConfig {
  static const String supabaseUrl = 'https://vvavgomyvhqkbfvbsusw.supabase.co';

  // Anon key is safe to embed - it's public and RLS protects data
  static const String supabaseAnonKey = 'sb_publishable_K8ZTb6kfA_K90tXH7UIq6Q_yYIv3EBu';

  static const String communeFunctionUrl = '$supabaseUrl/functions/v1/commune';

  // Rate limiting
  static const int maxFreeSessions = 3;

  // Prevent instantiation
  SupabaseConfig._();
}
