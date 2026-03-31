import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jkautomed/users/common/profile_chooser_dialog.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_users.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'common_widgets.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final otp;

  final bool otpSent;

  const VerificationScreen({super.key, required this.phoneNumber, required this.otpSent, required this.email, this.otp});

  @override
  State<StatefulWidget> createState() {
    return VerificationState();
  }

}

class VerificationState extends State<VerificationScreen> {
  final TextEditingController otpController = TextEditingController();


 @override
  void dispose() {
   otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (!widget.otpSent) {
      Future.delayed(const Duration(seconds: 0), () {
        CommonWidgets.showProgress();
        AjugnuAuth().resendOTP(widget.phoneNumber).then((message) {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showSuccess(context, 'OTP sent to your email address.');
        }, onError: (error) {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showError(context, error.toString());
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double logoSize = width * 0.65;

    return Scaffold(
      primary: true,
      extendBodyBehindAppBar: false,
      extendBody: false,
      backgroundColor: AjugnuTheme.appColor,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/gradient_background.png'), fit: BoxFit.cover)
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: width * 0.1, right: width * 0.1, left: width * 0.15),
                    child: Image.asset(
                      'assets/images/splacelogo.png',
                      width: logoSize,
                      height: logoSize * 0.9,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: width * 0.1, bottom: width * 0.05),
                        child: Text(
                          "We Sent verification code to your email address${widget.email.isNotEmpty ? ' ${widget.email}' : widget.email}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AjugnuTheme.appColorScheme.onPrimary,
                              fontSize: 14
                          ),
                        )
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "User One Time Otp: ${widget.otp}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, bottom: 12),
                    child: CommonWidgets.editbox(alignment: TextAlign.start, hint: "Enter OTP", maxLength: 4, controller: otpController, keyboardType: TextInputType.number, autofillHints: [AutofillHints.oneTimeCode], onEditingComplete: () => verifyOTP()),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: IconButton(
                        onPressed: () {
                          CommonWidgets.showProgress();
                          AjugnuAuth().resendOTP(widget.phoneNumber).then((response) {
                            CommonWidgets.removeProgress();
                            if (response.status) {
                              AjugnuFlushbar.showSuccess(context, response.message ?? 'OTP sent successfully.');
                            } else {
                              AjugnuFlushbar.showError(context, response.message ?? 'Something went wrong.');
                            }
                          }, onError: (error) {
                            CommonWidgets.removeProgress();
                            AjugnuFlushbar.showError(context, error.toString());
                          });
                        },
                        icon: const Text(
                          'Resend?',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w100,
                              fontSize: 14
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.1, right: width * 0.1, top: 5, bottom: 16),
                    child: ElevatedButton(
                      onPressed: () => verifyOTP(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color.fromARGB(255, 121, 255, 217))
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                          elevation: 5
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // void verifyOTP() {
  //   if (otpController.text.trim().isNotEmpty) {
  //     CommonWidgets.showProgress();
  //     AjugnuAuth().verifyOTP(widget.phoneNumber, otpController.text.trim()).then((response) {
  //       CommonWidgets.removeProgress();
  //       if (response.status) {
  //         AjugnuFlushbar.showSuccess(context, response.message ?? 'OTP sent successfully.');
  //         if (AjugnuAuth().getUser()?.oRole == 'both') {
  //           showDialog(context: context, useSafeArea: true, barrierDismissible: true, builder: (context) {
  //             return const ProfileChooserDialog(closeable: false);
  //           });
  //           return;
  //         }
  //         if (AjugnuAuth().getUser()?.role == 'supplier') {
  //           AjugnuNavigations.supplierHomeScreen();
  //         } else {
  //           // AjugnuNavigations.featuredProducts(type: AjugnuNavigations.typePush);
  //           AjugnuNavigations.customerHomeScreen(type: AjugnuNavigations.typeRemoveAllAndPush);
  //         }
  //       } else {
  //         AjugnuFlushbar.showError(context, response.message ?? 'Something went wrong.');
  //       }
  //     }, onError: (error) {
  //       CommonWidgets.removeProgress();
  //       AjugnuFlushbar.showError(context, error.toString());
  //     });
  //   } else {
  //     AjugnuFlushbar.showError(context, 'Please enter a valid one time code.');
  //   }
  // }

  void verifyOTP() {
    if (otpController.text.trim().isNotEmpty) {
      CommonWidgets.showProgress();

      AjugnuAuth()
          .verifyOTP(widget.phoneNumber, otpController.text.trim())
          .then((response) {
        CommonWidgets.removeProgress();

        if (response.status) {
          // AjugnuFlushbar.showSuccess(
          //   context,
          //   response.message ?? 'OTP verified successfully.',
          // );

          // hamesha customer home
          AjugnuNavigations.customerHomeScreen(
            type: AjugnuNavigations.typeRemoveAllAndPush,
          );
        } else {
          AjugnuFlushbar.showError(
            context,
            response.message ?? 'Something went wrong.',
          );
        }
      }, onError: (error) {
        CommonWidgets.removeProgress();
        AjugnuFlushbar.showError(context, error.toString());
      });
    } else {
      AjugnuFlushbar.showError(
        context,
        'Please enter a valid one time code.',
      );
    }
  }

}