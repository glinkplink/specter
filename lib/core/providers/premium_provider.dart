import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/revenuecat_service.dart';
import '../config/revenuecat_config.dart';

/// Premium subscription state
class PremiumState {
  final bool isPremium;
  final bool isLoading;
  final Offerings? offerings;
  final String? error;
  final bool isInitialized;
  final bool debugModeEnabled; // For web testing

  const PremiumState({
    this.isPremium = false,
    this.isLoading = false,
    this.offerings,
    this.error,
    this.isInitialized = false,
    this.debugModeEnabled = false,
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    Offerings? offerings,
    String? error,
    bool? isInitialized,
    bool? debugModeEnabled,
    bool clearError = false,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      offerings: offerings ?? this.offerings,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
      debugModeEnabled: debugModeEnabled ?? this.debugModeEnabled,
    );
  }
}

/// Premium provider notifier
///
/// Manages premium subscription state and RevenueCat integration
class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier() : super(const PremiumState()) {
    _initialize();
  }

  final _revenueCatService = RevenueCatService();
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  /// Initialize RevenueCat and check premium status
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load debug mode preference
      final debugMode = await _getDebugMode();

      if (kIsWeb) {
        // Web: Use debug mode only (RevenueCat doesn't support web)
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          debugModeEnabled: debugMode,
          isPremium: debugMode,
        );
        if (kDebugMode) {
          print('PremiumProvider: Web platform - debug mode: $debugMode');
        }
        return;
      }

      // Initialize RevenueCat SDK
      await _revenueCatService.initialize();

      // Check initial premium status
      final isPremium = await _revenueCatService.checkPremiumStatus();

      // Load offerings
      final offerings = await _revenueCatService.getOfferings();

      // Listen to customer info updates for real-time changes
      _customerInfoSubscription =
          _revenueCatService.customerInfoStream?.listen(
        (customerInfo) {
          final isPremium = customerInfo
                  .entitlements.all[RevenueCatConfig.premiumEntitlementId]
                  ?.isActive ??
              false;
          if (kDebugMode) {
            print('PremiumProvider: Customer info updated - isPremium: $isPremium');
          }
          state = state.copyWith(isPremium: isPremium);
        },
      );

      state = state.copyWith(
        isPremium: isPremium,
        offerings: offerings,
        isLoading: false,
        isInitialized: true,
      );

      if (kDebugMode) {
        print('PremiumProvider: Initialized - isPremium: $isPremium');
      }
    } catch (e) {
      if (kDebugMode) {
        print('PremiumProvider: Initialization error - $e');
      }
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: 'Failed to initialize premium features',
      );
    }
  }

  /// Purchase a subscription package
  ///
  /// Returns true if purchase succeeded
  /// Handles user cancellation gracefully (no error shown)
  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isPremium = await _revenueCatService.purchasePackage(package);

      state = state.copyWith(
        isPremium: isPremium,
        isLoading: false,
      );

      return isPremium;
    } on PlatformException catch (e) {
      // Handle specific error codes
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      String? errorMessage;
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled - don't show error
        errorMessage = null;
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        errorMessage = 'Payment pending - check back later';
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        errorMessage = 'You already own this subscription';
      } else {
        errorMessage = 'Purchase failed: ${e.message ?? 'Unknown error'}';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );

      if (kDebugMode) {
        print('PremiumProvider: Purchase error - $errorCode: ${e.message}');
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error: $e',
      );

      if (kDebugMode) {
        print('PremiumProvider: Purchase unexpected error - $e');
      }

      return false;
    }
  }

  /// Restore previous purchases
  ///
  /// Returns true if user has active premium subscription
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isPremium = await _revenueCatService.restorePurchases();

      state = state.copyWith(
        isPremium: isPremium,
        isLoading: false,
      );

      return isPremium;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to restore purchases',
      );

      if (kDebugMode) {
        print('PremiumProvider: Restore error - $e');
      }

      return false;
    }
  }

  /// Refresh premium status from RevenueCat
  Future<void> refreshPremiumStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isPremium = await _revenueCatService.checkPremiumStatus();
      state = state.copyWith(isPremium: isPremium, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh status',
      );
    }
  }

  /// Toggle debug premium mode (web only)
  Future<void> toggleDebugMode() async {
    if (!kIsWeb) return;

    final newDebugMode = !state.debugModeEnabled;
    await _saveDebugMode(newDebugMode);

    state = state.copyWith(
      debugModeEnabled: newDebugMode,
      isPremium: newDebugMode,
    );

    if (kDebugMode) {
      print('PremiumProvider: Debug mode toggled - $newDebugMode');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Debug mode persistence

  Future<bool> _getDebugMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('premium_debug_mode') ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('PremiumProvider: Failed to get debug mode - $e');
      }
      return false;
    }
  }

  Future<void> _saveDebugMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('premium_debug_mode', enabled);
    } catch (e) {
      if (kDebugMode) {
        print('PremiumProvider: Failed to save debug mode - $e');
      }
    }
  }

  @override
  void dispose() {
    _customerInfoSubscription?.cancel();
    super.dispose();
  }
}

/// Global premium provider
final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  return PremiumNotifier();
});
