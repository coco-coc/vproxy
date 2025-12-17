import 'package:in_app_purchase/in_app_purchase.dart';

// Gives the option to override in tests.
class IAPConnection {
  static InAppPurchase? _instance;
  static set instance(InAppPurchase value) {
    _instance = value;
  }

  static InAppPurchase get instance {
    _instance ??= InAppPurchase.instance;
    return _instance!;
  }
}

class ProductData {
  final String productId;
  final ProductType type;

  const ProductData(this.productId, this.type);
}

enum ProductType {
  subscription,
  nonSubscription,
}

const productDataMap = {
  'vproxy_pro_lifetime': ProductData(
    'vproxy_pro_lifetime',
    ProductType.nonSubscription,
  ),
  'vproxy_pro_android': ProductData(
    'vproxy_pro_android',
    ProductType.nonSubscription,
  ),
};
