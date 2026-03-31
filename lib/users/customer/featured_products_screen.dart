 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_product.dart';
import '../common/common_widgets.dart';
import '../common/products_grid_list.dart';
import 'backend/customer_product_repository.dart';

class FeaturedProductsScreen extends StatefulWidget {
  const FeaturedProductsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return FeaturedProductsState();
  }
}

class FeaturedProductsState extends State<FeaturedProductsScreen> {
  List<AjugnuProduct>? searchResults;

  void fetchFavouriteProducts() {
    CustomerProductRepository().getFeaturedProducts().then((results) {
      if (results.isNotEmpty) {
        setState(() {
          searchResults = results;
        });
      } else {
       // AjugnuNavigations.locationSelectorScreen(type: AjugnuNavigations.typeRemoveAllAndPush, forceToSelect: true);
      }
    }, onError: (error) {
      setState(() {
        searchResults = [];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () => fetchFavouriteProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
        appBar: CommonWidgets.appbar('You might like', showBackButton: false, systemUiOverlayStyle: const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white,
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark
        )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              searchResults == null ? ProductsGridList(
                enableShimmer: true,
                products: [
                  AjugnuProduct.dummy(),
                  AjugnuProduct.dummy(),
                  AjugnuProduct.dummy(),
                  AjugnuProduct.dummy(),
                ],
              ) : ProductsGridList(
                products: searchResults!,
                onUpdate: () => setState(() {}),
              ),
              const SizedBox(height: 0),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 50, right: MediaQuery.of(context).size.width * 0.095, left: MediaQuery.of(context).size.width * 0.095),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll<double>(0),
                        backgroundColor: const WidgetStatePropertyAll<Color>(Color(0xff040A05)),
                        side: const WidgetStatePropertyAll<BorderSide>(BorderSide(color: Color(0xffABFFE7))),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                    ),
                    onPressed: () {
                     // AjugnuNavigations.locationSelectorScreen(type: AjugnuNavigations.typeRemoveAllAndPush, forceToSelect: true);
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: CommonWidgets.text('Skip',
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            fontFamily: 'Aclonica',
                            textColor: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        )
    );
  }
}
