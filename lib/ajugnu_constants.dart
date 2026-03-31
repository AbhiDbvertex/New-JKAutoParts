
import 'package:flutter/material.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:jkautomed/users/common/products_grid_list.dart';

import 'models/ajugnu_product.dart';

const String ajugnuAppName = 'JkAutoParts';

class AjugnuTheme {
  // static const Color appColor = Color.fromARGB(255, 56, 74, 68);
  // static const Color appColor = Color.fromARGB(255, 90, 80, 200);
  static const Color appColor = Color(0xFF0D048C);
  // static const Color appColor = Colors.white;
  // static ColorScheme appColorScheme =
  //     ColorScheme.fromSeed(seedColor: appColor, brightness: Brightness.light);
  static ColorScheme appColorScheme =
  ColorScheme.fromSeed(seedColor: appColor);
  static const Color secondery = Color(0x662833FF);
// rgba(12, 3, 140, 1)
}


/*
class CustomPopup extends StatefulWidget {
  final List<AjugnuProduct>? randomProducts;

  const CustomPopup({super.key, this.randomProducts});

  @override
  State<StatefulWidget> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  late final List<AjugnuProduct>? randomProducts;

  @override
  void initState() {
    super.initState();
    randomProducts = widget.randomProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            // color: Theme.of(context).colorScheme.surface,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonWidgets.text('Popular Products', fontSize: 16),
              const SizedBox(height: 12.0),
              ProductsGridList(
                broadcastChanges: false,
                products: randomProducts??[],enableShimmer: false,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the popup
                },
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

class CustomPopup extends StatefulWidget {
  final List<AjugnuProduct>? randomProducts;

  const CustomPopup({super.key, this.randomProducts});

  @override
  State<StatefulWidget> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  late final List<AjugnuProduct>? randomProducts;

  @override
  void initState() {
    super.initState();
    randomProducts = widget.randomProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonWidgets.text('Popular Products', fontSize: 16),
              const SizedBox(height: 12.0),
              ProductsGridList(
                broadcastChanges: false,
                products: randomProducts ?? [],
                enableShimmer: false,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
