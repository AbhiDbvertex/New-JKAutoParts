import 'dart:async';
import 'dart:ui' as Img;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_product.dart';
import '../customer/backend/customer_product_repository.dart';
import '../customer/product_change_listeners.dart';
import 'AjugnuFlushbar.dart';
import 'backend/api_handler.dart';
import 'common_widgets.dart';


class ProductsGridList extends StatefulWidget {
  final List<AjugnuProduct> products;
  final int crossAxisCount;
  final double aspectRatio;
  final bool enableShimmer;
  final bool onlyKeepFavourites;
  final bool hideFavourite;
  final bool broadcastChanges;
  final EdgeInsets padding;


  final Function()? onUpdate;

  const ProductsGridList({super.key,
    required this.products,
    this.crossAxisCount = 2,
    this.aspectRatio = 0.87,
    this.enableShimmer = false,
    this.onlyKeepFavourites = false,
    this.hideFavourite = false,
    this.broadcastChanges = true,
    this.padding = const EdgeInsets.all(8.0),
    this.onUpdate
  });

  @override
  State<StatefulWidget> createState() {
    return ProductGridState();
  }
}

class ProductGridState extends State<ProductsGridList> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      padding: widget.padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: widget.aspectRatio,
      ),
      itemCount: widget.products.length,
      itemBuilder: (context, index) => widget.enableShimmer ? Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.3),
          highlightColor: Colors.white,
          child: const Card()
      ): ProductCard(product: widget.products[index], onlyKeepFavourites: widget.onlyKeepFavourites, hideFavourite: widget.hideFavourite, broadcastChanges: widget.broadcastChanges, onExpire: () {
        widget.products.removeAt(index);
        if (widget.onUpdate != null) {
          widget.onUpdate!();
        }
      }, ),
    );
  }
}

class ProductCard extends StatefulWidget {
  AjugnuProduct product;
  final bool onlyKeepFavourites;
  final bool hideFavourite;
  final bool broadcastChanges;
  final Function() onExpire;


  ProductCard({super.key, required this.product, required this.onlyKeepFavourites, required this.hideFavourite, required this.broadcastChanges, required this.onExpire});

  @override
  State<StatefulWidget> createState() {
    return ProductCardState();
  }
  
}

class ProductCardState extends State<ProductCard>{
  bool didIBroadcast = false;

  void onProductChange(AjugnuProduct product, bool completeProduct) {
    if (widget.product.id == product.id && !didIBroadcast) {
      if (completeProduct) {
        setState(() {
          widget.product = product;
        });
      } else {
        setState(() {
          widget.product.isRated = product.isRated;
        });
      }
    }
    if (didIBroadcast) {
      didIBroadcast = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    ProductChangeListeners.addListener(onProductChange);
  }

  @override
  void dispose() {
    ProductChangeListeners.removeListener(onProductChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.product.id,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 5,
        shadowColor: Colors.black,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            try {
              adebug("customerItemDetailScreen",tag: "Navigation");
              AjugnuNavigations.customerItemDetailScreen(product: widget.product);
            } catch (e) {
            adebug("yash: navigation error: $e",tag: "customerItemDetailScreen")     ;
            AjugnuFlushbar.showError(context,"Failed to open product details" );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.product.productImages.firstOrNull??'',
                placeholderFadeInDuration: Duration.zero,
                fit: BoxFit.cover,
                placeholder: (context, error) => Shimmer.fromColors(
                    baseColor: Colors.grey.withOpacity(0.3),
                    highlightColor: Colors.white,
                    child: Container(color: Colors.black12)
                ),
                errorWidget: (context, url, error) => Container(color: Colors.black12, child: const Icon(Icons.image_not_supported)),
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7),
                          Colors.transparent, Colors.transparent, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                ),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.7)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                          child: Icon(Icons.star_rounded, size: 20, color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
                          child: CommonWidgets.text(widget.product.averageRating.toStringAsFixed(0), fontFamily: 'Poly', fontSize: 17, textColor: Colors.white),
                        ),
                        const Spacer(),
                        Visibility(

                          visible: !widget.hideFavourite,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.product.isFavourite = !widget.product.isFavourite;
                              });
                              CustomerProductRepository().favourite(widget.product.id, removeFromFavourite: !widget.product.isFavourite).then((status) {
                                setState(() {
                                  if (!status) {
                                    widget.product.isFavourite = !widget.product.isFavourite;
                                  } else if (widget.onlyKeepFavourites) {
                                    widget.onExpire();
                                  }
                                });
                                if (widget.broadcastChanges) {
                                  didIBroadcast = true;
                                  ProductChangeListeners.broadcastChanges(widget.product);
                                }
                              }, onError: (error) {
                                setState(() {
                                  widget.product.isFavourite = !widget.product.isFavourite;
                                });
                                AjugnuFlushbar.showError(context, widget.product.isFavourite ? 'Something went wrong while removing product from your favourite list' : 'Something went wrong while adding product to your favourite list');
                              });
                            },
                            icon: Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(100)
                              ),

                              child: Align(
                                child: widget.product.isFavourite ? const Icon(Icons.favorite_rounded, size: 16, color: Colors.green) :  Icon(Icons.favorite_border_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.hideFavourite && widget.product.productRole != 'tools',
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CommonWidgets.text(widget.product.weight, textColor: Colors.white, fontSize: 17, fontFamily: 'Poly'),
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonWidgets.text(widget.product.productName, overflow: TextOverflow.ellipsis, maxLines: 1, textColor: Colors.white),
                      Row(
                        children: [

                          Expanded(child: CommonWidgets.text(widget.product.productType!="Unknown"
                              ?widget.product.productType:
                          widget.product.categoryName! !=""?widget.product.categoryName!:widget.product.toolFertilizerSize!,
                              textColor: Colors.white, fontFamily: 'Poly', fontSize: 16, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Card(
                            color: Colors.black,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Color.fromARGB(255, 121, 255, 217))
                            ),
                            clipBehavior: Clip.hardEdge,
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              child: Align(
                                child:  CommonWidgets.text("₹${widget.product.price}", fontFamily: 'Poly', fontSize: 16, textColor: Colors.white, overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  
}
