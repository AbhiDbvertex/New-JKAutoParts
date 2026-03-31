import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jkautomed/users/common/profile_chooser_dialog.dart';
import 'package:jkautomed/users/common/sign_in_screen.dart';

import '../../JKAutoMed/screens/favorite_screen.dart';
import '../../JKAutoMed/screens/order_history_screen.dart';
import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../customer/backend/cart_repository.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'common_widgets.dart';
import 'information_screen.dart';

class SettingsScreen extends StatefulWidget {

  final Function()? onExitCallbacks;

  const SettingsScreen({super.key, this.onExitCallbacks});

  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<SettingsScreen>{

  // @override
  // void initState() {
  //   super.initState();
  //
  //   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //       systemStatusBarContrastEnforced: false,
  //       statusBarColor: Colors.white,
  //       systemNavigationBarColor: Colors.white,
  //       systemNavigationBarDividerColor: Colors.transparent,
  //       systemNavigationBarIconBrightness: Brightness.dark,
  //       statusBarIconBrightness: Brightness.dark)
  //   );
  //
  //   //Setting SystmeUIMode
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  // }

  bool amISupplier() => AjugnuAuth().getUser()?.role == 'supplier';

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final iconSize = height * 0.03;

    ColorScheme colorScheme = AjugnuTheme.appColorScheme;

    return PopScope(
      onPopInvoked: (didPop) {
        if (widget.onExitCallbacks != null) {
          widget.onExitCallbacks!();
        }
      },
      canPop: false,
      child: Scaffold(
          backgroundColor: colorScheme.onPrimary,
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: AppBar(
              backgroundColor: colorScheme.onPrimary,
              automaticallyImplyLeading: false,
              forceMaterialTransparency: false,
              systemOverlayStyle: SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.white,
                  statusBarColor: AjugnuTheme.appColorScheme.onPrimary,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarIconBrightness: Brightness.dark
              ),
              title: Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 20
                    ),
                  )
              ),
              titleSpacing: 0,
            ),
          ),
          body: ListView(
            children: [
              const SizedBox(height: 18),
              createSettingTile(
                  iconSize: iconSize,
                  title: 'Edit Profile',
                  color: AjugnuTheme.appColorScheme.onSurface, icon: Icon(Icons.account_circle_outlined, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
                  onClick: () => amISupplier() ? AjugnuNavigations.supplierEditProfileScreen() : AjugnuNavigations.customerEditProfileScreen()
              ),
              Visibility(
                visible: !amISupplier(),
                child: createSettingTile(
                    iconSize: iconSize,
                    title: 'My Favourites',
                    color: AjugnuTheme.appColorScheme.onSurface,
                    icon: Icon(Icons.favorite_border_outlined, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
                    onClick: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> FavoriteScreen()));
                    }
                    // onClick: () => AjugnuNavigations.customerFavouriteScreen()
                ),
              ),
              Visibility(
                visible: !amISupplier(),
                child: createSettingTile(
                    iconSize: iconSize,
                    title: 'History',
                    color: AjugnuTheme.appColorScheme.onSurface,
                    icon: Icon(Icons.history, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
                    onClick: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderHistoryScreen()));
                    }
                    // onClick: () => AjugnuAuth().getUser()?.role == 'supplier' ? AjugnuNavigations.supplierOrderPageScreen() : AjugnuNavigations.customerOrderPageScreen()
                ),
              ),
              Visibility(
                visible: amISupplier(),
                child: createSettingTile(
                    iconSize: iconSize,
                    title: 'Order Page',
                    color: AjugnuTheme.appColorScheme.onSurface,
                    icon: Icon(Icons.info_outline, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
                    onClick: () => AjugnuNavigations.supplierOrderPageScreen()
                ),
              ),
              createSettingTile(
                  iconSize: iconSize,
                  title: 'T&C',
                  color: AjugnuTheme.appColorScheme.onSurface,
                  icon: Icon(CupertinoIcons.book, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
                  onClick: () => AjugnuNavigations.informationScreen(title: InformationScreen.titleT_C)
              ),
              createSettingTile(
                  iconSize: iconSize,
                  title: 'About Us',
                  color: AjugnuTheme.appColorScheme.onSurface,
                  icon: Icon(Icons.contact_support_outlined, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
                  onClick: () => AjugnuNavigations.informationScreen(title: InformationScreen.titleAboutUs)
              ),
              createSettingTile(
                  iconSize: iconSize,
                  title: 'Privacy Policy',
                  color: AjugnuTheme.appColorScheme.onSurface,
                  icon: Icon(Icons.privacy_tip_outlined, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
                  onClick: () => AjugnuNavigations.informationScreen(title: InformationScreen.titlePrivacyPolicy)
              ),
              createSettingTile(
                  iconSize: iconSize,
                  title: 'Change Password',
                  color: AjugnuTheme.appColorScheme.onSurface,
                  icon: Image(image: const AssetImage('assets/icons/protection.png'),  height: iconSize, width: iconSize, color: AjugnuTheme.appColorScheme.onSurface),
                  onClick: () => AjugnuNavigations.changePasswordScreen()
              ),
              Visibility(
                visible: amISupplier(),
                child: createSettingTile(
                    iconSize: iconSize,
                    title: 'Add Bank Details',
                    color: AjugnuTheme.appColorScheme.onSurface,
                    icon: Image(image: const AssetImage('assets/icons/bank.png'),  height: iconSize, width: iconSize, color: AjugnuTheme.appColorScheme.onSurface),
                    onClick: () => AjugnuNavigations.supplierAddBankDetailsScreen()
                ),
              ),
              // createSettingTile(
              //     iconSize: iconSize,
              //     title: 'Switch Profile',
              //     color: AjugnuTheme.appColorScheme.onSurface,
              //     icon: Icon(Icons.swap_horizontal_circle_outlined, color: AjugnuTheme.appColorScheme.onSurface, size: iconSize),
              //     onClick: () {
              //       showDialog(context: context, useSafeArea: true, barrierDismissible: true, builder: (context) {
              //         return ProfileChooserDialog(exclude: AjugnuAuth().getUser()?.role ??'', closeable: true,);
              //       });
              //     }
              // ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.04).copyWith(top: MediaQuery.of(context).size.height * 0.02),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                              side: BorderSide(color: AjugnuTheme.appColorScheme.onSurface)
                          ),
                          elevation: 5,
                          clipBehavior: Clip.hardEdge,
                          color: Theme.of(context).colorScheme.onPrimary,
                          child: InkWell(
                            onTap: () {
                              onLogoutRequest();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.019, horizontal: MediaQuery.of(context).size.width * 0.18),
                              child: Row(
                                  children: [
                                    Icon(
                                        Icons.logout,
                                        size: iconSize,
                                        color: AjugnuTheme.appColorScheme.onSurface
                                    ),
                                    Text(
                                      'LOG OUT',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AjugnuTheme.appColorScheme.onSurface,
                                          fontFamily: 'Roboto'
                                      ),
                                    )
                                  ]
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
      ),
    );
  }

  createSettingTile({required iconSize, required String title, required Color color, required Widget icon, Function()? onClick}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(26))
          ),
          elevation: 3,
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.onPrimary,
          child: InkWell(
            onTap: () {
              if (onClick != null) {
                onClick();
              }
            },
            child: ListTile(
              leading: icon,
              title: Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: color,
                    fontFamily: 'Roboto'
                ),
              ),
              trailing: Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: iconSize * 0.7,
                  color: color
              ),
            ),
          )
      ),
    );
  }

  void onLogoutRequest() {
    showDialog(context: context, useSafeArea: true, builder: (dialogContext) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: const BorderRadius.all(Radius.circular(60))
                ),
                padding: const EdgeInsets.only(top: 25, left: 24, bottom: 45, right: 24),
                child: Column(
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 0,
                      clipBehavior: Clip.hardEdge,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(1000))
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 36, top: 28, bottom: 28, right: 28),
                        child: Image(
                          image: AssetImage('assets/images/user_logout.png'),
                          height: 120,
                          width: 120,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(alignment: Alignment.center, child: Text(
                        'Are you sure to logout?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600
                        )
                    )),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:AjugnuTheme.appColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 30),
                                  elevation: 5
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                CommonWidgets.showProgress();
                                AjugnuAuth().logout().then((response) {
                                  CommonWidgets.removeProgress();
                                  if (response.status) {

                                   Navigator.push(context, MaterialPageRoute(builder: (context)=> SignInScreen()))  ;
                                    // AjugnuNavigations.SignInScreen();
                                    AjugnuFlushbar.showSuccess(context, response.message ?? "Successfully logged you out.");
                                  } else {
                                    AjugnuFlushbar.showError(context, response.message ?? 'Something went wrong.');
                                  }
                                }, onError: (error) {
                                  CommonWidgets.removeProgress();
                                  AjugnuFlushbar.showError(context, error.toString());
                                });
                              },
                              child: const Text(
                                  'YES',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)
                              )
                          ),
                          const Spacer(),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: AjugnuTheme.appColorScheme.inversePrimary, width: 1)
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 30),
                                  elevation: 5
                              ),
                              onPressed: () {
                                Navigator.of(context).pop('dialog');
                              },
                              child: const Text(
                                  'NO',
                                  style: TextStyle(color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500
                                  )
                              )
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}