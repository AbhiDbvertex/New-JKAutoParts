import 'package:jkautomed/models/ajugnu_product.dart';

import '../common/backend/api_handler.dart';

class ProductChangeListeners {
  static bool isThereAnyChanges = false;

  static List<Function(AjugnuProduct product, bool completeProduct)> listeners = [];

  static void clearChanges() => isThereAnyChanges = false;

  static void removeAllListeners() {
    listeners.clear();
  }

  static void removeListener(Function(AjugnuProduct product, bool completeProduct) listener) {
    listeners.remove(listener);
  }

  static void addListener(Function(AjugnuProduct product, bool completeProduct) listener) {
    listeners.add(listener);
  }

  static void broadcastChanges(AjugnuProduct product, {bool completeProduct = true}) {
    adebug('product changed {id: ${product.id}');
    isThereAnyChanges = true;
    listeners.forEach((listener) => listener(product, completeProduct));
  }
}