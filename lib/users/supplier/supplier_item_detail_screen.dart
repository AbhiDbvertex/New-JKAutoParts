import 'dart:async';

import 'package:jkautomed/ajugnu_navigations.dart';
import 'package:jkautomed/main.dart';
import 'package:jkautomed/models/ajugnu_product.dart';
import 'package:jkautomed/users/common/AjugnuFlushbar.dart';
import 'package:jkautomed/users/supplier/backend/product_repository.dart';
import 'package:jkautomed/users/supplier/supplier_home_screen.dart';
import 'package:jkautomed/users/supplier/supplier_my_items_screen.dart';
import 'package:jkautomed/users/common/settings_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../ajugnu_constants.dart';
import '../common/common_widgets.dart';
import 'backend/image_fullscreen_view.dart';

class SupplierItemDetailScreen extends StatefulWidget {
  final AjugnuProduct product;

  const SupplierItemDetailScreen({super.key, required this.product});

  @override
  State<StatefulWidget> createState() {
    return SupplierItemState();
  }

}

class SupplierItemState extends State<SupplierItemDetailScreen> with SingleTickerProviderStateMixin {
  PageController controller=PageController();
  late TabController tabController;

  int imageIndex = 0;
  bool reversing = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // bool last = false;
    // for (int i = 0; i < 15; i++) {
    //   last= !last;
    //
    //   widget.product.productImages.add(widget.product.productImages[last ? 0 : 1]);
    // }

    tabController = TabController(length: widget.product.productImages.length, vsync: this);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
      extendBody: false,
      extendBodyBehindAppBar: false,
      appBar: CommonWidgets.appbar(widget.product.productName, actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu selection
              if (value == 'Edit') {
                // Navigate to edit page
                AjugnuNavigations.supplierEditProductScreen(product: widget.product);
              } else if (value == 'Disable') {
                // Delete product
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
                            CommonWidgets.showProgress();
                            ProductRepository().deleteProduct(widget.product.id).then((v) {
                              CommonWidgets.removeProgress();
                              AjugnuNavigations.supplierHomeScreen();
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
                CommonWidgets.showQR(widget.product, showAction: false);
              }
            },
            itemBuilder: (BuildContext context) {
              return (widget.product.isApproved ? {'Edit', 'Disable', 'QR'} : {'Edit', 'QR'}).map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              })
                  .toList();
            },
          ),
        ),
      ], systemUiOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: AjugnuTheme.appColorScheme.onPrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark)
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.5,
              child: widget.product.productImages.isEmpty ? imageCard('',imageIndex) : Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  // reverse: true,
                  // physics: BouncingScrollPhysics(),
                  controller: controller,
                  onPageChanged: (index){
                    setState(() {
                      imageIndex = index;
                    });
                  },
                  children: widget.product.productImages.isNotEmpty ? widget.product.productImages.map((e) => imageCard(e,imageIndex)).toList() : [imageCard('', 0)]
                  // children: _screens,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1000)
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: TabBar(
                      controller: tabController,
                      dividerColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      tabAlignment: TabAlignment.center,
                      indicatorPadding: EdgeInsets.zero,
                      isScrollable: true,
                      indicator: const BoxDecoration(),
                      tabs: List.generate(widget.product.productImages.length, (index) {
                        return Tab(
                          icon: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: imageIndex == index ? Colors.green : Colors.black54,
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
                          colors: [Colors.white, Colors.white.withOpacity(0.0)],
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
                          colors: [Colors.white, Colors.white.withOpacity(0.0)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24),
              child: CommonWidgets.text("Description", maxLines: 1, fontWeight: FontWeight.w400, fontSize: 18),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24),
            //   child: CommonWidgets.text(widget.product.description, maxLines: 3, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: 'Poly'),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24),
              child: ReadMoreText(text: widget.product.description),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWidgets.text('Type', maxLines: 1, fontWeight: FontWeight.w400, fontSize: 13, textColor: Colors.black54),
                        const SizedBox(height: 4),
                        CommonWidgets.text(widget.product.productType, maxLines: 1, fontWeight: FontWeight.w400, fontSize: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWidgets.text('Size', maxLines: 1, fontWeight: FontWeight.w400, fontSize: 13, textColor: Colors.black54),
                        const SizedBox(height: 4),
                        CommonWidgets.text(widget.product.productSize, maxLines: 1, fontWeight: FontWeight.w400, fontSize: 16),
                      ],
                    ),
                  ),

                  // Expanded(
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       CommonWidgets.text('Level', maxLines: 1, fontWeight: FontWeight.w400, fontSize: 13, textColor: Colors.black54),
                  //       const SizedBox(height: 4),
                  //       CommonWidgets.text('Easy', maxLines: 1, fontWeight: FontWeight.w400, fontSize: 16),
                  //     ],
                  //   ),
                  // )
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget imageCard(String imageUrl,int  imageIndex) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: (){
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
          placeholder: (context, error) => Container(color: Colors.black12),
          errorWidget: (context, url, error) => const Image(image: AssetImage("assets/images/gradient_background.png"), fit: BoxFit.cover),
        ),
      ),
    );
  }
}