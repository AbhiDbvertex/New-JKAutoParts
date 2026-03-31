import 'package:flutter/material.dart';
import 'package:jkautomed/users/common/profile_chooser_dialog.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'common_widgets.dart';
import 'form_validator.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SignInState();
  }
}

class SignInState extends State<SignInScreen> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool? obscureText = true;

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double logoSize = width * 0.63;

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
                image: DecorationImage(
                    image: AssetImage('assets/images/gradient_background.png'),
                    fit: BoxFit.cover)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: width * 0.1,
                        right: width * 0.1,
                        left: width * 0.15),
                    child: Image.asset(
                      'assets/images/splacelogo.png',
                      width: logoSize,
                      // height: logoSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.08, vertical: 12),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, bottom: 12),
                    child: CommonWidgets.editbox(cursorColor: Colors.white,
                        alignment: TextAlign.start,
                        hint: "Enter Mobile Number",
                        maxLength: FormValidators.maxPhoneLength,
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        autofillHints: [AutofillHints.telephoneNumber]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 12),
                    child: CommonWidgets.editbox(cursorColor: Colors.white,
                        onTapIcon: () {
                          setState(() {
                            obscureText = !obscureText!;
                          });
                        },
                        suffix: obscureText!?Icons.visibility_off:Icons.visibility,
                        alignment: TextAlign.start,
                        hint: "Enter Your Password",
                        maxLength: FormValidators.maxPasswordLength,
                        controller: passwordController,
                        obscureText: obscureText,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: [AutofillHints.password],
                        onEditingComplete: () {
                          signIN();
                        }),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: IconButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          var error = FormValidators.isValidIndianPhone(
                              phoneNumberController.text.trim());
                          if (error == null) {
                            CommonWidgets.showProgress();
                            AjugnuAuth()
                                .resendOTP(phoneNumberController.text.trim())
                                .then((response) {
                              CommonWidgets.removeProgress();
                              if (response.status) {
                                AjugnuNavigations.forgotPasswordScreen(
                                    phoneNumber:
                                        phoneNumberController.text.trim());
                                AjugnuFlushbar.showSuccess(
                                    context,
                                    response.message ??
                                        'OTP sent successfully.');
                              } else {
                                AjugnuFlushbar.showError(
                                    context,
                                    response.message ??
                                        'Something went wrong.');
                              }
                            }, onError: (error) {
                              CommonWidgets.removeProgress();
                              AjugnuFlushbar.showError(
                                  context, error.toString());
                            });
                          } else {
                            AjugnuFlushbar.showError(context, error);
                          }
                        },
                        icon: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w100,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        signIN();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 121, 255, 217))),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 14),
                          elevation: 5),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.08, vertical: 12),
                        child: const Text(
                          'Don’t have an account? Sign Up',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                      onPressed: () => AjugnuNavigations.signUpScreen(),
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

  void signIN() {
    FocusManager.instance.primaryFocus?.unfocus();

    String phoneNumber = phoneNumberController.text.trim();
    String password = passwordController.text.trim();

    String? phoneNumberError = FormValidators.isValidIndianPhone(phoneNumber);
    String? passwordError = FormValidators.isValidPassword(password);
    if (phoneNumberError == null) {
      if (passwordError == null) {
        CommonWidgets.showProgress();
        AjugnuAuth().signIn(phoneNumber, password).then((response) {
          CommonWidgets.removeProgress();
          if (response.status) {
            if (AjugnuAuth().getUser()?.oRole == 'both') {
              showDialog(context: context, useSafeArea: true, barrierDismissible: true, builder: (context) {
                return const ProfileChooserDialog(closeable: false);
              });
              return;
            }
            if (AjugnuAuth().getUser()?.role == 'supplier') {
              AjugnuNavigations.supplierHomeScreen();
            } else {
              AjugnuNavigations.customerHomeScreen(showRandoomProductPopup: true);
            }
            AjugnuFlushbar.showSuccess(context, response.message ?? "Successfully logged IN");
          } else {
            if (response.message
                .toString()
                .toLowerCase()
                .contains('otp not verified')) {
              AjugnuNavigations.verificationScreen(phoneNumber: phoneNumber, email: "",);
            } else {
              AjugnuFlushbar.showError(context, response.message ?? 'Something went wrong.');
            }
          }
        }, onError: (error) {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showError(context, error.toString());
        });
      } else {
        AjugnuFlushbar.showError(context, passwordError);
      }
    } else {
      AjugnuFlushbar.showError(context, phoneNumberError);
    }
  }
}
