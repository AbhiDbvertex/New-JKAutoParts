import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_users.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'backend/api_handler.dart';
import 'common_widgets.dart';

class ProfileChooserDialog extends StatefulWidget {
  final String exclude;

  final bool closeable;

  const ProfileChooserDialog({super.key, this.exclude = '', this.closeable = false});

  @override
  State<StatefulWidget> createState() {
    return ProfileChooserState();
  }

}
class ProfileChooserState extends State<ProfileChooserDialog> {

  String role = '';

  @override
  void initState() {
    role = AjugnuAuth().getUser()?.role ?? 'supplier';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    double width = MediaQuery.of(context).size.width;
    double catImageSize = width * 0.28;

    return PopScope(
      canPop: false,
      child: Center(
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
                padding: const EdgeInsets.only(top: 48, left: 28, bottom: 45, right: 28),
                child: Column(
                  children: [
                    Align(alignment: Alignment.center, child: Text(
                        'Select Profile to Switch',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                    )),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  role = 'supplier';
                                });
                              },
                              icon: Stack(
                                children: [
                                  Card(
                                    color: colorScheme.inversePrimary,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(1000))
                                    ),
                                    child: ClipOval(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset(
                                            'assets/icons/supplier.png',
                                            height: catImageSize * 0.8,
                                            width: catImageSize * 0.8,
                                            fit: BoxFit.fill,
                                          ),
                                        )
                                    ),
                                  ),
                                  Visibility(
                                    visible: role == 'supplier',
                                    child: Padding(
                                      padding: EdgeInsets.only(left: catImageSize - (catImageSize * 0.35)),
                                      child: Card(
                                        color: colorScheme.inversePrimary,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(1000))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ClipOval(
                                            child: Image(
                                              image: const AssetImage('assets/images/tick.png'),
                                              height: catImageSize * 0.35,
                                              width: catImageSize * 0.35,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonWidgets.text('Supplier', fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  role = 'user';
                                });
                              },
                              icon: Stack(
                                children: [
                                  Card(
                                    color: colorScheme.inversePrimary,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(1000))
                                    ),
                                    child: ClipOval(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Image.asset(
                                            'assets/icons/customer.png',
                                            height: catImageSize * 0.8,
                                            width: catImageSize * 0.8,
                                            fit: BoxFit.contain,
                                          ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: role == 'user',
                                    child: Padding(
                                      padding: EdgeInsets.only(left: catImageSize - (catImageSize * 0.35)),
                                      child: Card(
                                        color: colorScheme.inversePrimary,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(1000))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ClipOval(
                                            child: Image(
                                              image: const AssetImage('assets/images/tick.png'),
                                              height: catImageSize * 0.35,
                                              width: catImageSize * 0.35,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonWidgets.text('Customer', fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          ],
                        )
                      ],
                    ),
                    if (AjugnuAuth().getUser()?.oRole != 'both' && AjugnuAuth().getUser()?.role != role) const SizedBox(height: 28),
                    if (AjugnuAuth().getUser()?.oRole != 'both' && AjugnuAuth().getUser()?.role != role) CommonWidgets.text("You didn't sign up as both, if you still want to switch to ${role == 'user' ? 'Customer' : 'Supplier'}, your dual profile will be created, click Ok to continue.", fontFamily: 'Poly', textColor: Colors.orangeAccent, fontSize: 14),
                    const SizedBox(height: 28),
                    widget.closeable ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AjugnuTheme.appColorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  elevation: 5
                              ),
                              onPressed: () async {
                                adebug('clicked');
                                if (widget.exclude.isEmpty || widget.exclude != role) {
                                  AjugnuUser user = AjugnuAuth().getUser()!;
                                  adebug('oRole is ${user.oRole}');

                                  if (user.oRole != 'both') {
                                    CommonWidgets.showProgress();
                                    var response = await AjugnuAuth().updateRole();
                                    if (response.status) {
                                      CommonWidgets.removeProgress();
                                      AjugnuFlushbar.showSuccess(context, response.message!);
                                    } else {
                                      CommonWidgets.removeProgress();
                                      AjugnuFlushbar.showError(context, response.message!);
                                      return;
                                    }
                                  }

                                  user = AjugnuAuth().getUser()!;
                                  user.oRole = 'both';
                                  user.role = role;
                                  await AjugnuAuth().saveUser(user);
                                  if (AjugnuAuth().getUser()?.role == 'supplier') {
                                    AjugnuNavigations.supplierHomeScreen();
                                  } else {
                                    AjugnuNavigations.customerHomeScreen(showRandoomProductPopup: true);
                                  }
                                }

                              },
                              child: Text(
                                  'OK',
                                  style: TextStyle(color: widget.exclude.isEmpty || widget.exclude != role ? Colors.white : Colors.white60, fontSize: 17, fontWeight: FontWeight.w500)
                              )
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AjugnuTheme.appColorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  elevation: 5
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)
                              )
                          ),
                        ),
                      ],
                    ) : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AjugnuTheme.appColorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
                            elevation: 5
                        ),
                        onPressed: () async {

                          if (widget.exclude.isEmpty || widget.exclude != role) {
                            AjugnuUser user = AjugnuAuth().getUser()!;
                            user.role = role;
                            AjugnuAuth().saveUser(user);
                            if (AjugnuAuth().getUser()?.role == 'supplier') {
                              AjugnuNavigations.supplierHomeScreen();
                            } else {
                              AjugnuNavigations.customerHomeScreen();
                            }
                          }
                        },
                        child: Text(
                            'OK',
                            style: TextStyle(color: widget.exclude.isEmpty || widget.exclude != role ? Colors.white : Colors.white60, fontSize: 17, fontWeight: FontWeight.w500)
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}