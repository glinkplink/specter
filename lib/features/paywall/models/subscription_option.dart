import 'package:purchases_flutter/purchases_flutter.dart';

/// Model representing a subscription option for display in the paywall
class SubscriptionOption {
  final Package package;
  final String title;
  final String description;
  final String price;
  final String pricePerMonth; // For annual plans
  final bool isPopular;
  final bool isBestValue;

  SubscriptionOption({
    required this.package,
    required this.title,
    required this.description,
    required this.price,
    required this.pricePerMonth,
    this.isPopular = false,
    this.isBestValue = false,
  });

  /// Create subscription option from RevenueCat package
  factory SubscriptionOption.fromPackage(Package package) {
    final product = package.storeProduct;
    
    // Check if annual by looking at the package type or identifier
    final isAnnual = package.packageType == PackageType.annual ||
        package.identifier.toLowerCase().contains('annual') ||
        package.identifier.toLowerCase().contains('yearly');

    String pricePerMonth = product.priceString;
    if (isAnnual) {
      // Calculate monthly price for annual plans
      final annualPrice = product.price;
      final monthlyPrice = annualPrice / 12;
      pricePerMonth = '\$${monthlyPrice.toStringAsFixed(2)}/mo';
    }

    return SubscriptionOption(
      package: package,
      title: product.title,
      description: product.description,
      price: product.priceString,
      pricePerMonth: pricePerMonth,
      isPopular: isAnnual,
      isBestValue: isAnnual,
    );
  }
}
