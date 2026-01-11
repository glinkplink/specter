import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/revenuecat_config.dart';

/// Service wrapper for RevenueCat SDK
///
/// Handles:
/// - SDK initialization
/// - Premium status checking
/// - Purchase flows
/// - Restore purchases
/// - Offline caching
class RevenueCatService {
  // Singleton pattern
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat SDK
  ///
  /// - Skips initialization on web platform (not supported)
  /// - Configures SDK with appropriate API key for platform
  /// - Sets log level based on debug mode
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // RevenueCat doesn't support web
        if (kDebugMode) {
          print('RevenueCat: Web platform detected, skipping initialization');
        }
        return;
      }

      // Set log level
      await Purchases.setLogLevel(
        RevenueCatConfig.enableDebugLogs ? LogLevel.debug : LogLevel.info,
      );

      // Configure for platform
      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(RevenueCatConfig.appleApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(RevenueCatConfig.googleApiKey);
      } else {
        if (kDebugMode) {
          print('RevenueCat: Unsupported platform $defaultTargetPlatform');
        }
        return;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;

      if (kDebugMode) {
        print('RevenueCat: Initialized successfully on $defaultTargetPlatform');
      }
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Initialization failed - $e');
      }
      rethrow;
    }
  }

  /// Check if user has premium entitlement
  ///
  /// - Returns cached status if offline or SDK not initialized
  /// - Updates cache on successful check
  Future<bool> checkPremiumStatus() async {
    if (!_isInitialized) {
      return await _getCachedPremiumStatus();
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements
              .all[RevenueCatConfig.premiumEntitlementId]?.isActive ??
          false;

      // Cache the status
      await _cachePremiumStatus(isPremium);

      if (kDebugMode) {
        print('RevenueCat: Premium status checked - $isPremium');
      }

      return isPremium;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Failed to check premium status - $e');
      }
      // Fallback to cached status
      return await _getCachedPremiumStatus();
    }
  }

  /// Get available subscription offerings
  ///
  /// Returns null if SDK not initialized or on error
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) return null;

    try {
      final offerings = await Purchases.getOfferings();
      if (kDebugMode) {
        print(
            'RevenueCat: Fetched offerings - ${offerings.current?.availablePackages.length ?? 0} packages');
      }
      return offerings;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Failed to fetch offerings - $e');
      }
      return null;
    }
  }

  /// Purchase a subscription package
  ///
  /// Returns true if purchase succeeded and user is now premium
  /// Throws PlatformException on errors (caller should handle)
  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      if (kDebugMode) {
        print('RevenueCat: Purchasing package ${package.identifier}');
      }

      final customerInfo = await Purchases.purchasePackage(package);
      final isPremium = customerInfo.entitlements
              .all[RevenueCatConfig.premiumEntitlementId]?.isActive ??
          false;

      await _cachePremiumStatus(isPremium);

      if (kDebugMode) {
        print('RevenueCat: Purchase completed - isPremium: $isPremium');
      }

      return isPremium;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Purchase failed - $e');
      }
      rethrow;
    }
  }

  /// Restore previous purchases
  ///
  /// Returns true if user has active premium entitlement after restore
  /// Throws on errors (caller should handle)
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      if (kDebugMode) {
        print('RevenueCat: Restoring purchases');
      }

      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements
              .all[RevenueCatConfig.premiumEntitlementId]?.isActive ??
          false;

      await _cachePremiumStatus(isPremium);

      if (kDebugMode) {
        print('RevenueCat: Restore completed - isPremium: $isPremium');
      }

      return isPremium;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Restore failed - $e');
      }
      rethrow;
    }
  }

  // Cache helpers for offline support

  Future<void> _cachePremiumStatus(bool isPremium) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RevenueCatConfig.premiumCacheKey, isPremium);
      await prefs.setInt(
        RevenueCatConfig.lastCheckCacheKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Failed to cache premium status - $e');
      }
    }
  }

  Future<bool> _getCachedPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getBool(RevenueCatConfig.premiumCacheKey) ?? false;
      if (kDebugMode) {
        print('RevenueCat: Using cached premium status - $cached');
      }
      return cached;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Failed to get cached status - $e');
      }
      return false;
    }
  }
}
