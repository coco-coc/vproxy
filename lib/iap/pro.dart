import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; // Add this import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vx/common/common.dart';
import 'package:http/http.dart' as http;
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/utils/logger.dart';
import 'package:flutter_common/auth/auth_provider.dart';

import './iap.dart';

const proLifetime = 'vproxy_pro_lifetime';
const androidProductId = 'vproxy_pro_android';

abstract class IAPState {}

enum StoreState { loading, available, notAvailable }

class IAPStateWithoutPurchaseDetail extends IAPState {
  IAPStateWithoutPurchaseDetail({
    required this.storeState,
    this.buying = false,
  });
  final StoreState storeState;
  final bool buying;

  IAPStateWithoutPurchaseDetail copyWith({
    StoreState? storeState,
    bool? buying,
  }) =>
      IAPStateWithoutPurchaseDetail(
        storeState: storeState ?? this.storeState,
        buying: buying ?? this.buying,
      );
}

class IAPStateWithPurchaseDetail extends IAPState {
  IAPStateWithPurchaseDetail({
    this.verifying,
    this.verifyFailed,
    this.success,
    required this.purchaseDetails,
    this.invalidPurchase,
  });
  final bool? verifying;
  // when server says it is invalid
  final bool? invalidPurchase;
  // when failed to verify
  final VerifyFailedException? verifyFailed;
  final bool? success;
  final PurchaseDetails purchaseDetails;

  IAPStateWithPurchaseDetail copyWith({
    bool? verifying,
    bool? invalidPurchase,
    VerifyFailedException? verifyFailed,
    bool? success,
    PurchaseDetails? purchaseDetails,
  }) =>
      IAPStateWithPurchaseDetail(
        verifying: verifying,
        invalidPurchase: invalidPurchase,
        verifyFailed: verifyFailed,
        success: success,
        purchaseDetails: purchaseDetails ?? this.purchaseDetails,
      );
}

class ProPurchases extends ChangeNotifier {
  String? userId;
  IAPState state;
  late StreamSubscription<List<PurchaseDetails>> _subscription; // Add this line
  late StreamSubscription<Session?> _userSubscription;
  List<PurchasableProduct> products = [];
  final iapConnection = IAPConnection.instance;
  final AuthProvider authProvider;

  Future<void> loadPurchases() async {
    final available = await iapConnection.isAvailable();
    if (!available) {
      state =
          IAPStateWithoutPurchaseDetail(storeState: StoreState.notAvailable);
      notifyListeners();
      return;
    }
    final ids = <String>{
      Platform.isAndroid ? androidProductId : proLifetime,
    };
    final response = await iapConnection.queryProductDetails(ids);
    products =
        response.productDetails.map((e) => PurchasableProduct(e)).toList();
    state = IAPStateWithoutPurchaseDetail(storeState: StoreState.available);
    notifyListeners();
    // _restore();
  }

  ProPurchases(this.authProvider)
      : state = IAPStateWithoutPurchaseDetail(storeState: StoreState.loading) {
    _userSubscription = authProvider.sessionStreams.listen((session) async {
      if (session != null && state is IAPStateWithPurchaseDetail) {
        final stateWithPurchaseDetail = state as IAPStateWithPurchaseDetail;
        if (stateWithPurchaseDetail.verifyFailed != null &&
            stateWithPurchaseDetail.verifyFailed!.message
                .contains('userId is null')) {
          await _verifyAndFulfill(stateWithPurchaseDetail);
        }
      }
    });
    final purchaseUpdated = iapConnection.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    loadPurchases();
  }

  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    logger.d('_onPurchaseUpdate: $purchaseDetailsList');
    for (var purchaseDetails in purchaseDetailsList) {
      try {
        await _handlePurchase(purchaseDetails);
      } catch (e) {
        logger.e(e);
        reportError('IAP _handlePurchase error', e);
      }
    }
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    inspect(purchaseDetails);
    print(
        'purchaseDetails: status: ${purchaseDetails.status}, orderId: ${purchaseDetails.purchaseID}, verificationData: ${purchaseDetails.verificationData.serverVerificationData}');
    state = IAPStateWithPurchaseDetail(purchaseDetails: purchaseDetails);
    notifyListeners();
    final stateWithPurchaseDetail = state as IAPStateWithPurchaseDetail;
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      // if restored, and current user is already lifetime pro, skip verification
      // if (purchaseDetails.status == PurchaseStatus.restored &&
      //     authBloc.state.user?.lifetimePro == true) {
      //   if (purchaseDetails.pendingCompletePurchase) {
      //     await iapConnection.completePurchase(purchaseDetails);
      //   }
      //   return;
      // }
      await _verifyAndFulfill(stateWithPurchaseDetail);
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      if (purchaseDetails.pendingCompletePurchase) {
        await iapConnection.completePurchase(purchaseDetails);
      }
      state = IAPStateWithoutPurchaseDetail(storeState: StoreState.available);
      notifyListeners();
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      reportError('purchaseDetails error', purchaseDetails.error);
      notifyListeners();
    } else if (purchaseDetails.status == PurchaseStatus.pending) {
      if (purchaseDetails.pendingCompletePurchase) {
        await iapConnection.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> reverify() async {
    await _verifyAndFulfill(state as IAPStateWithPurchaseDetail);
  }

  Future<void> restore() async {
    await iapConnection.restorePurchases();
  }

  Future<void> _verifyAndFulfill(
      IAPStateWithPurchaseDetail stateWithPurchaseDetail) async {
    logger.d('verifying: ${stateWithPurchaseDetail.purchaseDetails.status}');
    state = stateWithPurchaseDetail.copyWith(
      purchaseDetails: stateWithPurchaseDetail.purchaseDetails,
      verifying: true,
    );
    notifyListeners();
    // Send to server
    try {
      var validPurchase =
          await _verifyPurchase(stateWithPurchaseDetail.purchaseDetails);
      if (!validPurchase) {
        state = stateWithPurchaseDetail.copyWith(
          purchaseDetails: stateWithPurchaseDetail.purchaseDetails,
          invalidPurchase: true,
        );
        logger.e(
            'invalidPurchase: ${stateWithPurchaseDetail.purchaseDetails.status}');
        reportError(
            'invalidPurchase ${stateWithPurchaseDetail.purchaseDetails.toString()}',
            '无法验证购买');
      } else {
        logger.d('verify success');
        if (stateWithPurchaseDetail.purchaseDetails.pendingCompletePurchase) {
          await iapConnection
              .completePurchase(stateWithPurchaseDetail.purchaseDetails);
        }
        state = stateWithPurchaseDetail.copyWith(
          purchaseDetails: stateWithPurchaseDetail.purchaseDetails,
          success: true,
        );
        authProvider.refreshUser();
      }
    } catch (e) {
      state = stateWithPurchaseDetail.copyWith(
        purchaseDetails: stateWithPurchaseDetail.purchaseDetails,
        verifyFailed: VerifyFailedException(e.toString()),
      );
      logger.e(e);
      reportError('IAP verify error', e);
    } finally {
      notifyListeners();
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final url = Uri.parse(dartBackendUrl);
    final userId = this.userId ?? authProvider.currentSession?.user.id;
    if (userId == null) {
      throw Exception('userId is null');
    }
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authProvider.currentSession?.accessToken}',
    };
    final response = await http.post(
      url,
      body: jsonEncode({
        'source': purchaseDetails.verificationData.source,
        'productId': purchaseDetails.productID,
        'verificationData':
            purchaseDetails.verificationData.serverVerificationData,
        'userId': userId,
        'transactionId': purchaseDetails.purchaseID,
      }),
      headers: headers,
    );
    if (response.statusCode == 200) {
      if (response.body == 'valid and fulfilled') {
        return true;
      } else {
        return false;
      }
    } else if (response.statusCode == 500) {
      throw Exception('internal server error');
    } else {
      throw Exception('server returned ${response.statusCode}');
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
    logger.e(error);
    reportError('IAP updateStreamOnError', error);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _userSubscription.cancel();
    super.dispose();
  } // To here.

  Future<void> buy(PurchasableProduct product, String userId) async {
    assert(state is IAPStateWithoutPurchaseDetail);
    this.userId = userId;
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    switch (product.id) {
      case proLifetime || androidProductId:
        state = (state as IAPStateWithoutPurchaseDetail).copyWith(buying: true);
        notifyListeners();
        try {
          await iapConnection.buyNonConsumable(purchaseParam: purchaseParam);
        } catch (e) {
          state =
              (state as IAPStateWithoutPurchaseDetail).copyWith(buying: false);
          notifyListeners();
          if (e is PlatformException &&
              (e.message?.contains('cancelled') ?? false)) {
            return;
          }
          rethrow;
        }
      // if (state is IAPStateWithoutPurchaseDetail) {
      //   state =
      //       (state as IAPStateWithoutPurchaseDetail).copyWith(buying: false);
      //   notifyListeners();
      // }
      default:
        throw ArgumentError.value(
            product.productDetails, '${product.id} is not a known product');
    }
  }
}

class ProductPro {}

enum ProductStatus {
  purchasable,
  purchased,
  pending,
}

class PurchasableProduct {
  String get id => productDetails.id;
  String get title => productDetails.title;
  String get description => productDetails.description;
  String get price => productDetails.price;
  ProductStatus status;
  ProductDetails productDetails;

  PurchasableProduct(this.productDetails) : status = ProductStatus.purchasable;
}

class VerifyFailedException implements Exception {
  final String message;
  VerifyFailedException(this.message);

  String toLocalString(BuildContext context) {
    if (message.contains('userId is null')) {
      return AppLocalizations.of(context)!.pleaseLoginFirst;
    }
    if (message.contains('internal server error')) {
      return AppLocalizations.of(context)!.serverError;
    }
    return message;
  }
}
