import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jkautomed/users/customer/product_change_listeners.dart';
import 'package:shimmer/shimmer.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_cart_product.dart';
import '../../models/ajugnu_product.dart';
import '../common/AjugnuFlushbar.dart';
import '../common/backend/ajugnu_auth.dart';
import '../common/backend/api_handler.dart';
import '../common/common_widgets.dart';
import '../common/products_grid_list.dart';
import '../supplier/backend/image_fullscreen_view.dart';
import 'backend/cart_repository.dart';
import 'backend/customer_product_repository.dart';

class CustomerItemDetailScreen extends StatefulWidget {
  final AjugnuProduct product;

  const CustomerItemDetailScreen({super.key, required this.product});

  @override
  State<StatefulWidget> createState() {
    return CustomerItemState();
  }
}

class CustomerItemState extends State<CustomerItemDetailScreen>
    with SingleTickerProviderStateMixin {
  PageController controller = PageController();
  late TabController tabController;
  var scrollController = ScrollController();

  int imageIndex = 0;
  bool reversing = false;
  Timer? timer;

  List<AjugnuCartProduct>? products;

  List<AjugnuProduct>? fertilizers;
  int fertilizerCurrentPage = 0;
  int fertilizerTotalPage = 0;

  List<AjugnuProduct>? tools;
  int toolsCurrentPage = 0;
  int toolsTotalPage = 0;

  List<AjugnuProduct>? similarProducts;

  void fetchCartProducts() {
    // if (CartRepository().doesCartProductsAvailableLocally()) {
    //   setState(() {
    //     if (CartRepository().cartProducts!.isEmpty) {
    //       products = [];
    //     } else {
    //       products = CartRepository().cartProducts!;
    //     }
    //   });
    // } else {
      CartRepository().getCartProducts().then((products) {
        adebug("getCartProducts($products)");
        setState(() {
          if (products.cartProducts.isEmpty) {
            this.products = [];
          } else {
            this.products = products.cartProducts;
          }
        });
      }, onError: (error) {
        adebug("getCartProducts($error)");
        setState(() {
          this.products = [];
        });
      });
    // }
  }

  void fetchFertilizer(int page) {
    if (widget.product.productRole != 'fertilizer' && widget.product.supplierId is String) {
      CustomerProductRepository()
          .getFertilizerProducts(widget.product.supplierId)
          .then((products) {
        setState(() {
          fertilizers = products.item;
          fertilizerCurrentPage = products.currentPage;
          fertilizerTotalPage = products.totalPages;
        });
      }, onError: (error) {
        adebug(error, tag: 'fertilizers');
        setState(() {
          fertilizers = [];
        });
      });
    } else {
      setState(() {
        fertilizers = [];
      });
    }
  }

  void fetchTools(int page) {
    if (widget.product.productRole != 'tools' && widget.product.supplierId is String) {
      CustomerProductRepository()
          .getToolProducts(widget.product.supplierId)
          .then((products) {
        setState(() {
          tools = products.item;
          toolsCurrentPage = products.currentPage;
          toolsTotalPage = products.totalPages;
        });
      }, onError: (error) {
        setState(() {
          tools = [];
        });
      });
    } else {
      setState(() {
        tools = [];
      });
    }
  }

  void fetchSimilarProducts() {
    adebug(widget.product.id);
    CustomerProductRepository().getSimilarProducts(widget.product.id).then(
        (products) {
      setState(() {
        similarProducts = products;
      });
    }, onError: (error) {
      setState(() {
        similarProducts = [];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      fetchCartProducts();
      fetchFertilizer(1);
      fetchTools(1);
      fetchSimilarProducts();
    });
    // bool last = false;
    // for (int i = 0; i < 15; i++) {
    //   last= !last;
    //
    //   widget.product.productImages.add(widget.product.productImages[last ? 0 : 1]);
    // }

    tabController =
        TabController(length: widget.product.productImages.length, vsync: this);

    if (widget.product.productImages.length > 1) {
      timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (imageIndex == widget.product.productImages.length - 1) {
          reversing = true;
        } else if (imageIndex == 0) {
          reversing = false;
        }
        int newIndex = imageIndex + (reversing ? -1 : 1);
        tabController.animateTo(newIndex);
        await controller.animateToPage(
          newIndex,
          curve: Curves.linearToEaseOut,
          duration: const Duration(milliseconds: 900),
        );
        controller.jumpToPage(newIndex);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var addedToCart = products != null &&
        products!.where((p) => p.product.id == widget.product.id).isNotEmpty;
    return Scaffold(
      backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
      extendBody: false,
      extendBodyBehindAppBar: false,
      appBar: CommonWidgets.appbar(widget.product.productName,
          actions: [
            widget.product.productRole != 'tools' &&
                    widget.product.productRole != 'fertilizer'
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.product.isFavourite =
                              !widget.product.isFavourite;
                        });
                        CustomerProductRepository()
                            .favourite(widget.product.id,
                                removeFromFavourite:
                                    !widget.product.isFavourite)
                            .then(
                                (status) => setState(() {
                                      ProductChangeListeners.broadcastChanges(
                                          widget.product);
                                      if (!status) {
                                        widget.product.isFavourite =
                                            !widget.product.isFavourite;
                                      }
                                    }), onError: (error) {
                          setState(() {
                            widget.product.isFavourite =
                                !widget.product.isFavourite;
                          });
                          AjugnuFlushbar.showError(
                              context,
                              !widget.product.isFavourite
                                  ? 'Something went wrong while adding product to your favourite list'
                                  : 'Something went wrong while removing product from your favourite list');
                        });
                      },
                      icon: widget.product.isFavourite
                          ? const Icon(Icons.favorite_rounded,
                              color: Colors.green)
                          : const Icon(Icons.favorite_border_rounded),
                    ))
                : const SizedBox(width: 48),
          ],
          systemUiOverlayStyle: SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              statusBarColor: AjugnuTheme.appColorScheme.onPrimary,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.dark)),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            physics: const ScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 18),
                    child: Hero(
                      tag: widget.product.id,
                      child: PageView(
                          scrollDirection: Axis.horizontal,
                          // reverse: true,
                          // physics: BouncingScrollPhysics(),
                          controller: controller,
                          onPageChanged: (index) {
                            setState(() {
                              imageIndex = index;
                            });
                          },
                          children: widget.product.productImages.isNotEmpty
                              ? widget.product.productImages
                                  .map((e) => imageCard(e))
                                  .toList()
                              : [imageCard('')]
                          // children: _screens,
                          ),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000)),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: TabBar(
                          controller: tabController,
                          dividerColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          tabAlignment: TabAlignment.center,
                          indicatorPadding: EdgeInsets.zero,
                          isScrollable: true,
                          indicator: const BoxDecoration(),
                          tabs: List.generate(
                              widget.product.productImages.length, (index) {
                            return Tab(
                              icon: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: imageIndex == index
                                      ? Colors.green
                                      : Colors.black54,
                                  borderRadius: BorderRadius.circular(1000),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.0)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.0)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.product.productRole == 'fertilizer',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 24),
                    child: CommonWidgets.text("Other Details",
                        maxLines: 1, fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                ),
                Visibility(
                  visible: widget.product.productRole == 'tools',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 24),
                    child: CommonWidgets.text("Other Details",
                        maxLines: 1, fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                ),
                // Visibility(
                //   visible: widget.product.productRole == 'fertilizer',
                 // child: Padding(
                   // padding: const EdgeInsets.symmetric(
                     //   vertical: 6.0, horizontal: 24),
                    //child: Text.rich(TextSpan(
                //         text: 'Product Weight: ',
                //         style: TextStyle(
                //             color: Colors.grey.shade500,
                //             fontSize: 13,
                //             fontFamily: 'Poly'),
                //         children: [
                //           TextSpan(
                //             text: widget.product.weight,
                //             style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //                 fontFamily: 'Poly'),
                //           )
                //         ])),
                //   ),
                // ),
                Visibility(
                visible: widget.product.productRole == 'fertilizer',
                  child: buildProductDetails(widget.product,true,"fertilizer"),
    
                ),
                Visibility(
                  visible: widget.product.productRole == 'tools',
                  child:buildProductDetails(widget.product,false,"tools")
                ),
                Visibility(
                  visible: widget.product.productRole != 'tools' &&
                      widget.product.productRole != 'fertilizer',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 24),
                    child: CommonWidgets.text("Description",
                        maxLines: 1, fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                ),
                Visibility(
                  visible: widget.product.productRole != 'tools' &&
                      widget.product.productRole != 'fertilizer',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 24),
                    child: ReadMoreText(text: widget.product.description),
                  ),
                ),
                Visibility(
                  visible: widget.product.productRole != 'tools' &&
                      widget.product.productRole != 'fertilizer',
                  child:buildProductDetails(widget.product,false,"item")
                ),

                Visibility(
                    visible: widget.product.productRole != 'tools' &&
                        widget.product.productRole != 'fertilizer',
                    child: const SizedBox(height: 4)),
                Visibility(
                    visible: widget.product.productRole != 'tools' &&
                        widget.product.productRole != 'fertilizer',
                    child: section('Similar Type', similarProducts, false)),
                Visibility(
                    visible: widget.product.productRole != 'tools' &&
                        widget.product.productRole != 'fertilizer',
                    child: section('Fertilizers', fertilizers, true)),
                Visibility(
                    visible: widget.product.productRole != 'tools' &&
                        widget.product.productRole != 'fertilizer',
                    child: section('Tools', tools, true)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.24),
                // Visibility(
                //   visible: false,
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 18),
                //         child: ElevatedButton(
                //           style: ButtonStyle(
                //               elevation: const WidgetStatePropertyAll<double>(0),
                //               backgroundColor: const WidgetStatePropertyAll<Color>(Color(0xff040A05)),
                //               side: const WidgetStatePropertyAll<BorderSide>(BorderSide(color: Color(0xffABFFE7))),
                //               shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                //           ),
                //           onPressed: () async {
                //             if (addedToCart) {
                //               if (CartRepository().doesCartProductsAvailableLocally()) {
                //                 CartRepository().cartProducts = null;
                //               }
                //               CommonWidgets.showProgress();
                //               CartRepository().removeFromCart(widget.product.id).then((v) {
                //                 CommonWidgets.removeProgress();
                //                 // if (widget.onDetailChanged != null) {
                //                 //   widget.onDetailChanged!();
                //                 // }
                //                 Navigator.of(context).pop();
                //                 AjugnuFlushbar.showSuccess(context, 'Product removed from your cart');
                //               }, onError: (error) {
                //                 CommonWidgets.removeProgress();
                //                 AjugnuFlushbar.showError(context, error.toString());
                //               });
                //             } else if (widget.product.quantity > 0) {
                //               if (CartRepository().doesCartProductsAvailableLocally()) {
                //                 CartRepository().cartProducts = null;
                //               }
                //               CommonWidgets.showProgress();
                //               CartRepository().addToCart(widget.product.id).then((v) {
                //                 CommonWidgets.removeProgress();
                //                 // if (widget.onDetailChanged != null) {
                //                 //   widget.onDetailChanged!();
                //                 // }
                //                 Navigator.of(context).pop();
                //                 AjugnuFlushbar.showSuccess(context, 'Product added to your cart');
                //               }, onError: (error) {
                //                 CommonWidgets.removeProgress();
                //                 AjugnuFlushbar.showError(context, error.toString());
                //               });
                //             }
                //           },
                //           child: Center(
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(vertical: 14),
                //               child: CommonWidgets.text(addedToCart ? 'Remove From Cart' : 1 > widget.product.quantity ? 'Out Of Stock' : 'Add To Cart',
                //                   fontWeight: FontWeight.w400,
                //                   fontSize: 20,
                //                   fontFamily: 'Aclonica',
                //                   textColor: Colors.white),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // )
              ],
            ),
          ),
          if (widget.product.supplierId is! Map) Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(
                      255,
                      228,
                      244,
                      214,
                    ),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        topLeft: Radius.circular(8))),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  children: [
                    widget.product.quantity > 0
                        ? Expanded(
                            child: ElevatedButton(
                            style: ButtonStyle(
                                elevation:
                                    const WidgetStatePropertyAll<double>(0),
                                backgroundColor:
                                    const WidgetStatePropertyAll<Color>(
                                        Color(0xff040A05)),
                                side: const WidgetStatePropertyAll<BorderSide>(
                                    BorderSide(color: Color(0xffABFFE7))),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            onPressed: () async {
                              var pinList = <int>[];
                              if (widget.product.supplierId is Map) {
                                dynamic temp_supp_id = {};
                                temp_supp_id = widget.product.supplierId;
                                if (temp_supp_id.containsKey('pin_code')) {
                                  if (temp_supp_id['pin_code'] != null) {
                                    pinList = temp_supp_id['pin_code'];

                                    bool? hasMatchingPins = AjugnuAuth()
                                        .getUser()
                                        ?.pinCode!
                                        .any((pin) => pinList.contains(pin));

                                    if (hasMatchingPins??false) {
                                      debugPrint("njdebug" +
                                          "There is a matching pin between the two lists.");
                                    } else {
                                      debugPrint("njdebug" +
                                          "There are no matching pin between the two lists.");
                                      AjugnuFlushbar.showError(context,
                                          "Product is not in range".toString());
                                      return;
                                    }
                                  }
                                }
                              }

                              if (addedToCart) {
                                if (CartRepository()
                                    .doesCartProductsAvailableLocally()) {
                                  CartRepository().cartProducts = null;
                                }
                                CommonWidgets.showProgress();
                                CartRepository()
                                    .removeFromCart(widget.product.id)
                                    .then((v) {
                                  CommonWidgets.removeProgress();
                                  // if (widget.onDetailChanged != null) {
                                  //   widget.onDetailChanged!();
                                  // }
                                  Navigator.of(context).pop();
                                  AjugnuFlushbar.showSuccess(context,
                                      'Product removed from your cart');
                                }, onError: (error) {
                                  CommonWidgets.removeProgress();
                                  AjugnuFlushbar.showError(
                                      context, error.toString());
                                });
                              } else if (widget.product.quantity > 0) {
                                if (CartRepository()
                                    .doesCartProductsAvailableLocally()) {
                                  CartRepository().cartProducts = null;
                                }
                                CommonWidgets.showProgress();
                                CartRepository()
                                    .addToCart(widget.product.id)
                                    .then((v) {
                                  CommonWidgets.removeProgress();
                                  // if (widget.onDetailChanged != null) {
                                  //   widget.onDetailChanged!();
                                  // }
                                  Navigator.of(context).pop();
                                  AjugnuFlushbar.showSuccess(
                                      context, 'Product added to your cart');
                                }, onError: (error) {
                                  CommonWidgets.removeProgress();
                                  AjugnuFlushbar.showError(
                                      context, error.toString());
                                });
                              }
                            },
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: CommonWidgets.text(
                                    addedToCart
                                        ? 'Remove From Cart'
                                        : 1 > widget.product.quantity
                                            ? 'Out Of Stock'
                                            : 'Add To Cart',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    fontFamily: 'Aclonica',
                                    alignment: TextAlign.center,
                                    textColor: Colors.white),
                              ),
                            ),
                          ))
                        : SizedBox(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll<double>(0),
                            backgroundColor:
                                const WidgetStatePropertyAll<Color>(
                                    Color(0xff040A05)),
                            side: const WidgetStatePropertyAll<BorderSide>(
                                BorderSide(color: Color(0xffABFFE7))),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onPressed: () async {
                          var pinList = <int>[];
                          pinList.clear();
                          if (widget.product.supplierId is Map) {
                            dynamic temp_supp_id = {};
                            temp_supp_id = widget.product.supplierId;
                            if (temp_supp_id.containsKey('pin_code')) {
                              if (temp_supp_id['pin_code'] != null) {
                                pinList = temp_supp_id['pin_code'];

                                bool? hasMatchingPins = AjugnuAuth()
                                    .getUser()
                                    ?.pinCode!
                                    .any((pin) => pinList.contains(pin));

                                if (hasMatchingPins != null &&
                                    hasMatchingPins == true) {
                                  debugPrint("njdebug" +
                                      "There is a matching pin between the two lists.");
                                } else {
                                  debugPrint("njdebug" +
                                      "There are no matching pin between the two lists.");
                                  AjugnuFlushbar.showError(context,
                                      "Product is not in range".toString());
                                  return;
                                }
                              }
                            }
                          }

                          if (addedToCart) {
                            AjugnuNavigations.customerHomeScreen(pageIndex: 0);
                          } else if (widget.product.quantity > 0) {
                            if (CartRepository()
                                .doesCartProductsAvailableLocally()) {
                              CartRepository().cartProducts = null;
                            }
                            CommonWidgets.showProgress();
                            CartRepository().addToCart(widget.product.id).then(
                                (v) {
                              CommonWidgets.removeProgress();
                              AjugnuNavigations.customerHomeScreen(
                                  pageIndex: 0);
                              AjugnuFlushbar.showSuccess(
                                  context, 'Product added to your cart');
                            }, onError: (error) {
                              CommonWidgets.removeProgress();
                              AjugnuFlushbar.showError(
                                  context, error.toString());
                            });
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: CommonWidgets.text(
                                1 > widget.product.quantity
                                    ? 'Out Of Stock'
                                    : 'Buy Now',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                fontFamily: 'Aclonica',
                                alignment: TextAlign.center,
                                textColor: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: CollapsingButtons(scrollController: scrollController, addedToCart: addedToCart, product: widget.product),
    );
  }

  section(String title, List<AjugnuProduct>? items, bool hideFavourite) {
    return Visibility(
      visible: items == null || items.isNotEmpty == true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24),
            child: items == null
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.withOpacity(0.3),
                    highlightColor: Colors.white,
                    child: Container(
                        child: CommonWidgets.text(title,
                            maxLines: 1,
                            fontWeight: FontWeight.w400,
                            fontSize: 17)),
                  )
                : CommonWidgets.text(title,
                    maxLines: 1, fontWeight: FontWeight.w400, fontSize: 17),
          ),
          items == null
              ? Shimmer.fromColors(
                  baseColor: Colors.grey.withOpacity(0.3),
                  highlightColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 24),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.46,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Container(
                            height: MediaQuery.of(context).size.width * 0.45,
                            width: MediaQuery.of(context).size.width * 0.45,
                            margin: const EdgeInsets.only(
                                top: 6, bottom: 6, right: 6),
                            child: Card(
                              elevation: 0,
                            )),
                        itemCount: 2,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.46,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Container(
                          height: MediaQuery.of(context).size.width * 0.45,
                          width: MediaQuery.of(context).size.width * 0.45,
                          margin: const EdgeInsets.only(
                              top: 6, bottom: 6, right: 6),
                          child: ProductCard(
                            product: items[index],
                            onlyKeepFavourites: false,
                            onExpire: () {},
                            broadcastChanges: true,
                            hideFavourite: hideFavourite,

                          )),
                      itemCount: items.length,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget imageCard(String imageUrl) {
    return Card(
      color: Colors.grey,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          if (imageUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(
                  imageUrls: widget.product.productImages,
                  imageIndex: imageIndex,
                  tag: 'imageHero$imageIndex',
                ),
              ),
            );
          }
        },
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholderFadeInDuration: Duration.zero,
          fit: BoxFit.cover,
          placeholder: (context, error) => Container(
            color: Colors.black12,
          ),
          errorWidget: (context, url, error) => const Image(
              image: AssetImage("assets/images/gradient_background.png"),
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget buildProductDetails(AjugnuProduct product,bool isProductWeight,type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 30,
            runSpacing: 10,
            children: [
              if(type.toString()!="tools")
              buildDetailColumn('Type', product.productType!="Unknown"?product.productType:product.categoryName!),
              if(type.toString()!="fertilizer")
              buildDetailColumn('Size',  product.productSize!="Unknown"?product.productSize:product.toolFertilizerSize!),
             // buildDetailColumn('Level', 'Easy'),

              // Product Weight sirf tab dikhe jab available ho
              if (isProductWeight)
                buildDetailColumn('Product Weight', "${product.weight} Kg"),

              buildDetailColumn('Price', "₹ ${product.price}"),
            ],
          ),
        ],
      ),
    );
  }
  Widget buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonWidgets.text(title,
            maxLines: 1, fontWeight: FontWeight.w400, fontSize: 13, textColor: Colors.black54),
        const SizedBox(height: 4),
        CommonWidgets.text(value,
            maxLines: 1, fontWeight: FontWeight.w400, fontSize: 16),
      ],
    );
  }

}
