// import 'package:jkautomed/models/ajugnu_product.dart';

import 'ajugnu_product.dart';

class AjugnuCartProduct {
  final String idd;
  int? originalQuantity;
  int quantity;
  AjugnuProduct product;

  AjugnuCartProduct({
    required this.idd,
    required this.quantity,
     this.originalQuantity,
    required this.product
  });
}