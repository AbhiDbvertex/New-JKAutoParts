
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'common_widgets.dart';
import 'form_validator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String phoneNumber;

  const ForgotPasswordScreen({super.key, required this.phoneNumber});

  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscureText1 = true;
  bool obscureText2 = true;

  @override
  void dispose() {
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double logoSize = width * 0.85;

    return Scaffold(
      primary: true,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AjugnuTheme.appColor,
      appBar: CommonWidgets.appbar('Forgot Password', color: Colors.white, systemUiOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light
      )),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/gradient_background.png'), fit: BoxFit.cover)
            ),
            padding: EdgeInsets.only(top: width * 0.12),
            child: Container(
              padding: EdgeInsets.only(top: width * 0.12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/splacelogo.png',
                      width: MediaQuery.of(context).size.width,
                      height: logoSize * 0.45,
                      fit: BoxFit.fitWidth,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: width * 0.1, bottom: width * 0.05),
                          child: Text(
                            "We Sent verification code to your registered email address",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AjugnuTheme.appColorScheme.onPrimary,
                              fontSize: 14
                            ),
                          )
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, bottom: 4),
                      child: CommonWidgets.editbox(cursorColor: Colors.white, controller: otpController, alignment: TextAlign.start, maxLength: 4, hint: "Enter OTP", keyboardType: TextInputType.number, autofillHints: [AutofillHints.oneTimeCode]),
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
                      padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, bottom: 12, top: 4),
                      child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, maxLength: FormValidators.maxPasswordLength, hint: "Enter new password", obscureText: obscureText1, suffix: obscureText1?Icons.visibility_off:Icons.visibility, controller: passwordController, keyboardType: TextInputType.visiblePassword, autofillHints: [AutofillHints.newPassword], onTapIcon: () {
                        setState(() {
                          obscureText1 = !obscureText1;
                        });
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, bottom: 12),
                      child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, maxLength: FormValidators.maxPasswordLength, hint: "Confirm Password", obscureText: obscureText2, suffix: obscureText2?Icons.visibility_off:Icons.visibility, controller: confirmPasswordController, keyboardType: TextInputType.visiblePassword, autofillHints: [AutofillHints.newPassword], onEditingComplete: () => reset(), onTapIcon: () {
                        setState(() {
                          obscureText2 = !obscureText2;
                        });
                      },),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.1, right: width * 0.1, top: 5, bottom: 14),
                      child: ElevatedButton(
                        onPressed: () {
                          reset();
                        },
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
                          'Reset',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void reset() {
    var otp = otpController.text.trim();
    var password = passwordController.text.trim();
    var confirmPassword = confirmPasswordController.text.trim();

    var passwordError = FormValidators.isValidPassword(password);

    if (otp.length == 4) {
      if (passwordError == null) {
        if (password == confirmPassword) {
          CommonWidgets.showProgress();
          AjugnuAuth().resetPassword(widget.phoneNumber, otp, password).then((response) {
            CommonWidgets.removeProgress();
            if (response.status) {
              AjugnuNavigations.signInScreen();
              AjugnuFlushbar.showSuccess(context, "${response.message ?? 'Password changed successfully.'} Please login again with your new password.");
            } else {
              AjugnuFlushbar.showError(context, response.message ?? 'Something went wrong.');
            }
          }, onError: (error) {
            CommonWidgets.removeProgress();
            AjugnuFlushbar.showError(context, error.toString());
          });
        } else {
          AjugnuFlushbar.showError(context, "Password does not match.");
        }
      } else {
        AjugnuFlushbar.showError(context, passwordError);
      }
    } else {
      AjugnuFlushbar.showError(context, "Please enter your valid one time code.");
    }

  }

}