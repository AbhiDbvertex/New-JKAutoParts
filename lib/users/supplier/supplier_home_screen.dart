import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/ajugnu_navigations.dart';
import 'package:jkautomed/users/common/settings_screen.dart';
import 'package:jkautomed/users/supplier/supplier_my_items_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupplierHomeScreen extends StatefulWidget {
   const SupplierHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SupplierHomeState();
  }
}

class SupplierHomeState extends State<SupplierHomeScreen> {
  PageController controller = PageController();

  int pageIndex = 0;

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
      body: PageView(
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        // reverse: true,
        // physics: BouncingScrollPhysics(),
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        children: [
          Center(child: SupplierMyItemsScreen()),
          Center(child: SettingsScreen(onExitCallbacks: () async {
            await controller.animateToPage(
              0,
              curve: Curves.linearToEaseOut,
              duration: const Duration(milliseconds: 200),
            );
            controller.jumpToPage(0);
          })),
        ],
        // children: _screens,
      ),
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
              if (index == 0) {
                AjugnuNavigations.supplierAddProductScreen();
                return;
              }
              await controller.animateToPage(
                index - 1,
                curve: Curves.linearToEaseOut,
                duration: const Duration(milliseconds: 200),
              );
              controller.jumpToPage(index - 1);
            },
            items: [
              BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1000)),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      "assets/icons/icon_add.png",
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                    ),
                  ),
                  label: "Add",
                  tooltip: 'Add New Course'),
              BottomNavigationBarItem(
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: pageIndex == 0
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
                        color: pageIndex == 0
                            ? AjugnuTheme.appColor
                            : Colors.white,
                      ),
                    ),
                  ),
                  label: "Home",
                  tooltip: "Supplier home screen"),
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
                      child: Image.asset("assets/icons/icon_user.png",
                          height: 22,
                          width: 22,
                          color: pageIndex == 1
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
