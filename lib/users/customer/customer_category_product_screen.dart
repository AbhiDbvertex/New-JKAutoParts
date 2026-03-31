
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ajugnu_constants.dart';
import '../../main.dart';
import '../../models/ajugnu_product.dart';
import '../common/common_widgets.dart';
import '../common/products_grid_list.dart';
import 'backend/customer_product_repository.dart';


class CustomerCategoryProductScreen extends StatefulWidget {
  final String categoryName;
  final String categoryID;

  const CustomerCategoryProductScreen({super.key, required this.categoryName, required this.categoryID});

  @override
  State<StatefulWidget> createState() {
    return CustomerCategoryProductState();
  }
}

class CustomerCategoryProductState extends State<CustomerCategoryProductScreen> {
  List<AjugnuProduct>? searchResults;

  void fetchFavouriteProducts() {
    CustomerProductRepository().getProductsByCategoryId(widget.categoryID).then((results) {
      if (results.isNotEmpty) {
        setState(() {
          searchResults = results;
        });
      } else {
        setState(() {
          searchResults = [];
        });
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
        appBar: CommonWidgets.appbar(widget.categoryName, systemUiOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: AjugnuTheme.appColorScheme.onPrimary
        )),
        body: searchResults == null ? SingleChildScrollView(
          child: ProductsGridList(
            enableShimmer: true,
            products: [
              AjugnuProduct.dummy(),
              AjugnuProduct.dummy(),
              AjugnuProduct.dummy(),
              AjugnuProduct.dummy(),
            ],
          ),
        ) : searchResults!.isEmpty ? Center(
          child: Card(
            elevation: 0,
            color: AjugnuTheme.appColorScheme.surface,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/empty_list.png',
                    height: MediaQuery.of(context).size.width * 0.3,
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CommonWidgets.text('There are no product in this category.', alignment: TextAlign.center, textColor: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ) : SingleChildScrollView(
          child: ProductsGridList(
            products: searchResults!, broadcastChanges: true,
          ),
        )
    );
  }
}