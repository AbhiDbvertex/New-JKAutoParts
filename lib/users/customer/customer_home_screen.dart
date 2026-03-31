import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../JKAutoMed/screens/get_card_screen.dart';
import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_product.dart';
import '../../models/ajugnu_users.dart';
import '../common/backend/ajugnu_auth.dart';
import '../common/backend/api_handler.dart';
import '../common/settings_screen.dart';
import 'backend/cart_count_emitter.dart';
import 'backend/cart_repository.dart';
import 'backend/customer_product_repository.dart';
import 'customer_categories_screen.dart';
import 'my_cart_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int pageIndex;
  final bool? showRandomProducts;

  const CustomerHomeScreen(
      {super.key, this.pageIndex = 1, this.showRandomProducts = false});

  @override
  State<StatefulWidget> createState() {
    return CustomerHomeState();
  }
}

class CustomerHomeState extends State<CustomerHomeScreen> {
  int pageIndex = 1;

  List<AjugnuProduct>? randomProducts;
  int notificationCounts = 0;
  int cartCounts = 0;

  late List<StatefulWidget> screens = [
    // MyCartScreen.CardScreen(onExitCallbacks: onScreenExit),
    MyCartScreens(hideButton: "hidebutton",),
    const CustomerCategoriesScreen(),
    SettingsScreen(onExitCallbacks: onScreenExit),
  ];

  onScreenExit() {
    setState(() {
      pageIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();

    init();

    //pageIndex = widget.pageIndex;

    CartCountEmitter.listen((counts) {
      if (cartCounts != counts) {
        adebug("count = $cartCounts");
        setState(() {
          cartCounts = counts;

        });
      }
    });
  }

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AjugnuUser? user = AjugnuAuth().getUser();
      if (user!.pinCode == null ||
          (user.pinCode?.isEmpty ?? true) == true ||
          (user.pinCode?.every((pin) => pin == null || pin.isEmpty) ?? true) ==
              true) {
        adebug('pushing');
        await AjugnuNavigations.locationSelectorScreen(
            forceToSelect: true,
            onLocationChanged: () {
              setState(() {
                screens[1] = const CustomerCategoriesScreen();
              });

              if (widget.showRandomProducts != null &&
                  widget.showRandomProducts == true) {
                CustomerProductRepository()
                    .getRandomProducts()
                    .then((randomProducts) {
                  if (randomProducts.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomPopup(randomProducts: randomProducts);
                      },
                    );
                  }
                });
              } else {
                debugPrint("debug:init show products false");
              }
            });
      }
      CartRepository().getCartProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          systemOverlayStyle: SystemUiOverlayStyle(
              systemNavigationBarColor: AjugnuTheme.appColor,
              statusBarColor: AjugnuTheme.appColorScheme.onPrimary,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.light),
        ),
      ),
      // floatingActionButton: pageIndex == 1
      //     ? FloatingActionButton(
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(1000),
      //             side: const BorderSide(
      //                 color: Color.fromARGB(255, 121, 255, 217), width: 1)),
      //         onPressed: () {
      //           AjugnuNavigations.qrCodeScanScreen();
      //         },
      //         backgroundColor: Colors.black,
      //         child: const Icon(
      //           Icons.qr_code_scanner_outlined,
      //           color: Colors.white,
      //         ),
      //       )
      //     : null,
      body: screens[pageIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            color: AjugnuTheme.appColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16), topLeft: Radius.circular(16))),
        child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            onTap: (index) async {
              setState(() {
                pageIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: pageIndex == 0
                            ? BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1000),
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 121, 255, 217)))
                            : null,
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/icons/icon_shopping.png",
                          height: 22,
                          width: 22,
                          fit: BoxFit.contain,
                          color: pageIndex == 0
                              ? AjugnuTheme.appColor
                              : Colors.white,
                        ),
                      ),
                      if (cartCounts > 0)
                        Positioned(
                            right: 0,
                            top: 0,
                            child: Badge.count(count: cartCounts))
                    ],
                  ),
                  label: "Cart",
                  tooltip: 'Cart'),
              BottomNavigationBarItem(
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: pageIndex == 1
                        ? BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1000),
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 121, 255, 217)))
                        : null,
                    child: Center(
                      child: Image.asset(
                        "assets/icons/icon_home.png",
                        height: 22,
                        width: 22,
                        fit: BoxFit.contain,
                        color: pageIndex == 1
                            ? AjugnuTheme.appColor
                            : Colors.white,
                      ),
                    ),
                  ),
                  label: "Home",
                  tooltip: "home screen"),
              BottomNavigationBarItem(
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: pageIndex == 2
                        ? BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1000),
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 121, 255, 217)))
                        : null,
                    child: Center (
                      child: Image.asset("assets/icons/icon_user.png",
                          height: 22,
                          width: 22,
                          color: pageIndex == 2
                              ? AjugnuTheme.appColor
                              : Colors.white,
                          fit: BoxFit.contain),
                    ),
                  ),
                  label: "Profile",
                  tooltip: "My Profile")
            ]),
      ),
    );
  }
}
