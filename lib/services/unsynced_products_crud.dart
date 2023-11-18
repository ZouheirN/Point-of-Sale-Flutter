import 'package:hive_flutter/hive_flutter.dart';

class UnSyncedProducts {
  static final unSyncedProductsBox = Hive.box('unSyncedProducts');

  static void addUnSyncedProduct({
    required String barcode,
    required String name,
    required String category,
    String? arabicName,
    required double price,
    required double price2,
    required double vatPerc,
    required double quantity,
    String? location,
    String? expiryDate,
  }) async {
    unSyncedProductsBox.add({
      'barcode': barcode,
      'description': name,
      'category': category,
      'ar_desc': arabicName,
      'price': price,
      'price2': price2,
      'vat_perc': vatPerc,
      'quantity': quantity,
      'location': location,
      'expiry': expiryDate,
    });
  }

  static List getUnSyncedProducts() {
    return unSyncedProductsBox.values.toList();
  }

  static void deleteUnSyncedProduct(String barcode) {
    unSyncedProductsBox.deleteAt(
      unSyncedProductsBox.values
          .toList()
          .indexWhere((element) => element['barcode'] == barcode),
    );
  }
}
