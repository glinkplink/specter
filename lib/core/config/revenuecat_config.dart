/// RevenueCat configuration for in-app purchases and subscriptions
///
/// API Keys Setup:
/// 1. Create a RevenueCat account at https://app.revenuecat.com
/// 2. Create a new project
/// 3. Get your API keys from Settings > API Keys
/// 4. Replace the placeholder keys below with your real keys
/// 5. IMPORTANT: Add this file to .gitignore when using real keys
///
/// Products Setup (in RevenueCat Dashboard):
/// - Create entitlement: "premium"
/// - Create products: premium_monthly, premium_annual
/// - Link products to premium entitlement
class RevenueCatConfig {
  // RevenueCat Public API Keys
  // These keys work for iOS and Android in test/sandbox mode
  // For production, switch to your prod_ keys
  static const String appleApiKey = 'test_RQGXUFuRlZkIPUAzGLvcEPxBadY';
  static const String googleApiKey = 'test_RQGXUFuRlZkIPUAzGLvcEPxBadY';

  // Entitlement identifier - Must match RevenueCat dashboard
  static const String premiumEntitlementId = 'premium';

  // Offering identifier - Default is fine unless you create custom offerings
  static const String defaultOfferingId = 'default';

  // SharedPreferences cache keys for offline support
  static const String premiumCacheKey = 'premium_status_cache';
  static const String lastCheckCacheKey = 'premium_last_check';

  // Debug logging - Set to false in production
  static const bool enableDebugLogs = true;

  // Prevent instantiation
  RevenueCatConfig._();
}
