import 'package:jkautomed/ajugnu_navigations.dart';
import 'package:jkautomed/users/common/backend/api_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:shimmer/shimmer.dart';
import '../../main.dart';
import '../../models/ajugnu_product.dart';
import '../../users/supplier/backend/product_repository.dart';
import '../common/AjugnuFlushbar.dart';

class SupplierMyItemsScreen extends StatefulWidget {
  const SupplierMyItemsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SupplierMyItemState();
  }
}

class SupplierMyItemState extends State<SupplierMyItemsScreen> {
  List<AjugnuProduct> products = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  bool isThereAnyNotifications = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts(showAnimation: true);
  }

  Future<void> _fetchProducts({bool showAnimation = false}) async {
    if (isLoading || currentPage > totalPages) return;

    setState(() {
      isLoading = showAnimation;
    });

    try {
      final result = await ProductRepository().getProducts(currentPage: currentPage);
      setState(() {
        products.addAll(result.data);
        currentPage = result.currentPage;
        totalPages = result.totalPages;
        isLoading = false;
        isThereAnyNotifications = result.notificationCounts > 0;
      });
    } catch (error) {
      if (showAnimation) {
        setState(() {
          isLoading = false;
        });
      }
      // Handle error (e.g., show a snackbar)
    }
  }

  void _loadMoreProducts() {
    if (currentPage < totalPages && !isLoading) {
      setState(() {
        currentPage++;
      });
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        leading: const SizedBox(width: 12),
        title: Center(
          child: CommonWidgets.text('Home', fontSize: 18),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: AjugnuTheme.appColorScheme.onPrimary,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        actions: [
          Stack(
            children: [
              Card(
                margin: EdgeInsets.only(right: 16),
                elevation: 0,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                color: Colors.black12,
                child: InkWell(
                  onTap: () => AjugnuNavigations.supplierNotificationsScreen(onNotificationRead: () => setState(() {
                    isThereAnyNotifications = false;
                  })),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Image.asset("assets/icons/icon_notification.png", height: 19, width: 19),
                  ),
                ),
              ),
              Visibility(
                visible: isThereAnyNotifications,
                child: Positioned(
                  left: 34,
                  top: 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    height: 6,
                    width: 6,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body:  isLoading ? Center(
        child: ListView(
          children: [AjugnuProduct.dummy(), AjugnuProduct.dummy(), AjugnuProduct.dummy(), AjugnuProduct.dummy()].map((product) => Card(
            color: const Color.fromARGB(255, 246, 246, 246),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)
            ),
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.35,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.3),
                      highlightColor: Colors.white,
                      child: const Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.hardEdge,
                        elevation: 0
                      )
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey.withOpacity(0.3),
                            highlightColor: Colors.white,
                            child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: CommonWidgets.text(product.productName, overflow: TextOverflow.ellipsis, maxLines: 1)),
                          ),
                          Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10000),
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.3),
                        highlightColor: Colors.white,
                        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: CommonWidgets.text("Quantity: ${product.quantity}", overflow: TextOverflow.ellipsis, maxLines: 1, textColor: Colors.black54),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.3),
                        highlightColor: Colors.white,
                        child: Container(
                            decoration: BoxDecoration(
                                color: product.isApproved ? const Color.fromARGB(255, 152, 244, 183) : const Color.fromARGB(255, 255, 149, 0).withOpacity(0.5),
                                borderRadius:BorderRadius.circular(20)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            margin: const EdgeInsets.only(top: 8),
                            child: CommonWidgets.text(product.isApproved ? 'Approved' : 'Pending', overflow: TextOverflow.ellipsis, maxLines: 1, fontSize: 15, textColor: Colors.black, fontFamily: 'Poly')
                        )),

                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ) :  NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              !isLoading) {
            _loadMoreProducts();
          }
          return false;
        },
        child: products.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          itemCount: products.length + (currentPage < totalPages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == products.length) {
              // Display a loading indicator at the end of the list
              return const Center(child: CircularProgressIndicator());
            }

            final product = products[index];
            return Card(
              color: Color.fromARGB(255, 246, 246, 246),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)
              ),
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 12),
              child: InkWell(
                onTap: () => AjugnuNavigations.supplierItemDetailScreen(product: product),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.35,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Card(
                            margin: EdgeInsets.zero,
                            clipBehavior: Clip.hardEdge,
                            child: product.productImages.isNotEmpty ? CachedNetworkImage(
                              height: MediaQuery.of(context).size.width * 0.35,
                              width: MediaQuery.of(context).size.width * 0.4,
                              imageUrl: product.productImages.isNotEmpty ? product.productImages[0] : '',
                              placeholderFadeInDuration: Duration.zero,
                              fit: BoxFit.cover,
                              placeholder: (context, error) => Container(color: Colors.black26),
                              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_sharp),
                            ) : Icon(Icons.image_not_supported_sharp, size: MediaQuery.of(context).size.width * 0.2, color: Colors.black26),
                          ),
                        ),
                        Positioned(
                            left: MediaQuery.of(context).size.width * 0.26,
                            top: MediaQuery.of(context).size.width * 0.28,
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.black87, size: 18),
                                const SizedBox(width: 3),
                                CommonWidgets.text(product.averageRating.toString(), textColor: Colors.black87, fontSize: 16, fontFamily: 'Poly')
                              ],
                            )
                        )
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: CommonWidgets.text(product.productName, overflow: TextOverflow.ellipsis, maxLines: 1)),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  // Handle menu selection
                                  if (value == 'Edit') {
                                    // Navigate to edit page
                                    AjugnuNavigations.supplierEditProductScreen(product: product);
                                  } else if (value == 'Disable') {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button to dismiss
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Disable Product'),
                                          content: const Text('Do you want to Disable this product? You will have to contact admin to restore your product.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Disable'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                CommonWidgets.showProgress();
                                                ProductRepository().deleteProduct(product.id).then((v) {
                                                  setState(() {
                                                    product.isApproved = false;
                                                  });
                                                  CommonWidgets.removeProgress();
                                                  AjugnuFlushbar.showSuccess(getAjungnuGlobalContext(), 'Product deleted successfully.');
                                                }, onError: (error) {
                                                  CommonWidgets.removeProgress();
                                                  AjugnuFlushbar.showError(getAjungnuGlobalContext(), error);
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else if (value == 'QR') {
                                    CommonWidgets.showQR(product);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return (product.isApproved ? {'Edit', 'Disable', 'QR'} : {'Edit', 'QR'}).map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  })
                                      .toList();
                                },
                              ),
                            ],
                          ),
                          CommonWidgets.text("Quantity: ${product.quantity}", overflow: TextOverflow.ellipsis, maxLines: 1, textColor: Colors.black54),
                          Container(
                            decoration: BoxDecoration(
                              color: product.isApproved ? const Color.fromARGB(255, 152, 244, 183) : const Color.fromARGB(255, 255, 149, 0).withOpacity(0.5),
                              borderRadius:BorderRadius.circular(20)
                            ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              margin: const EdgeInsets.only(top: 8),
                              child: CommonWidgets.text(product.isApproved ? 'Approved' : 'Pending', overflow: TextOverflow.ellipsis, maxLines: 1, fontSize: 15, textColor: Colors.black, fontFamily: 'Poly')
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card.outlined(
      color: AjugnuTheme.appColorScheme.onPrimary,
      margin: const EdgeInsets.symmetric(vertical: 46, horizontal: 26),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                child: CommonWidgets.text('No Product\nAvailable', textColor: Colors.black26, fontSize:30, alignment: TextAlign.center),
              )
          ),
          Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                  child: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                          text: 'please add your product ',
                          style: TextStyle(
                            fontFamily: "Poly",
                            fontSize: 17,

                          ),
                          children: [
                            TextSpan(
                                text: "here",
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  AjugnuNavigations.supplierAddProductScreen();
                                },
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 68, 111, 5),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color.fromARGB(255, 68, 111, 5)
                                )
                            )
                          ]
                      )
                  )
                // child: CommonWidgets.text('please add your product here', textColor: Colors.black26, fontSize: 15, alignment: TextAlign.center),
              )
          )
        ],
      ),
    );
  }
}
