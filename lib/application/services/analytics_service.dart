import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// This provider will be used to access the AnalyticsService from the UI.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String category,
    double? price,
  }) async {
    await _analytics.logViewItem(
      currency: 'USD',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: category,
          price: price,
        ),
      ],
    );
  }

  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    String? category,
  }) async {
    await _analytics.logAddToCart(
      currency: 'USD',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: category,
          price: price,
        ),
      ],
    );
  }

  Future<void> logBeginCheckout({required double value}) async {
    await _analytics.logBeginCheckout(value: value, currency: 'USD');
  }

  Future<void> logPurchase({
    required String orderId,
    required double value,
  }) async {
    await _analytics.logPurchase(
      transactionId: orderId,
      value: value,
      currency: 'USD',
    );
  }

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
