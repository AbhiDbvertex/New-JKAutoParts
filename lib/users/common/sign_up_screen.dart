import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'backend/google_apis.dart';
import 'common_widgets.dart';
import 'form_validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SignUpState();
  }

}

class SignUpState extends State<SignUpScreen> {
  bool isUser = true;
  bool isSupplier = false;

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscureText1 = true;
  bool obscureText2 = true;

  @override
  void dispose() {
    fullnameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    pinCodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double logoSize = width * 0.65;
    return Scaffold(
      primary: true,
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
                    padding: EdgeInsets.only(top: height * 0.07, right: width * 0.1, left: width * 0.15),
                    child: Image.asset(
                      'assets/images/splacelogo.png',
                      width: MediaQuery.sizeOf(context).width,
                      // height: logoSize * 0.6,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, maxLength: FormValidators.maxNameChunkLength, textCapitalization: TextCapitalization.words, hint: "Full Name", controller: fullnameController, keyboardType: TextInputType.name, autofillHints: [AutofillHints.name]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 12),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, hint: "Mobile Number", maxLength: FormValidators.maxPhoneLength, controller: phoneNumberController, keyboardType: TextInputType.phone, autofillHints: [AutofillHints.telephoneNumber]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 12),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, hint: "Email Address", controller: emailController, keyboardType: TextInputType.emailAddress, autofillHints: [AutofillHints.email]),
                  ),
                  if (isSupplier) Padding(
                    padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 12),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, maxLength: FormValidators.maxPinCodeLength, hint: "Add Your Pin Code No.", controller: pinCodeController, keyboardType: TextInputType.number, autofillHints: [AutofillHints.postalCode]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 12),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, hint: "Create Password", maxLength: FormValidators.maxPasswordLength, obscureText: obscureText1, suffix: obscureText1?Icons.visibility_off:Icons.visibility, controller: passwordController, keyboardType: TextInputType.visiblePassword, autofillHints: [AutofillHints.newPassword], onTapIcon: () {
                      setState(() {
                        obscureText1 = !obscureText1;
                      });
                    },),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 12),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, alignment: TextAlign.start, hint: "Confirm Password", maxLength: FormValidators.maxPasswordLength, obscureText: obscureText2, suffix: obscureText2?Icons.visibility_off:Icons.visibility, controller: confirmPasswordController, keyboardType: TextInputType.visiblePassword, autofillHints: [AutofillHints.newPassword], onTapIcon: () {
                      setState(() {
                        obscureText2 = !obscureText2;
                      });
                    },),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        signup(fullnameController.text.trim(), phoneNumberController.text.trim(), emailController.text.trim(), passwordController.text.trim(), confirmPasswordController.text.trim());
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
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 12),
                        child: const Text(
                          'Already have an account? Sign In',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14
                          ),
                        ),
                      ), onPressed: () {
                      if (kDebugMode) {
                        print("ishwar:temp signing");
                      }
                      AjugnuNavigations.signInScreen();
                    },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> signup(
      String fullName,
      String mobile,
      String email,
      String password,
      String confirmPassword,
      ) async {

    String postalCode = pinCodeController.text.trim();

    var fullNameError = FormValidators.isValidFullname(fullName);
    var mobileError = FormValidators.isValidIndianPhone(mobile);
    var emailError = FormValidators.isValidEmail(email);
    var passwordError = FormValidators.isValidPassword(password);
    var pinCodeError = FormValidators.isValidPostalCode(postalCode);

    if (!isUser && !isSupplier) {
      AjugnuFlushbar.showError(context, 'Please select at least one profile type.');
      return;
    }

    if (fullNameError != null) {
      AjugnuFlushbar.showError(context, fullNameError);
      return;
    }
    if (mobileError != null) {
      AjugnuFlushbar.showError(context, mobileError);
      return;
    }
    if (emailError != null) {
      AjugnuFlushbar.showError(context, emailError);
      return;
    }
    if (pinCodeError != null && !(isUser && !isSupplier)) {
      AjugnuFlushbar.showError(context, pinCodeError);
      return;
    }
    if (passwordError != null) {
      AjugnuFlushbar.showError(context, passwordError);
      return;
    }
    if (password != confirmPassword) {
      AjugnuFlushbar.showError(context, 'Password does not match.');
      return;
    }

    CommonWidgets.showProgress();

    // Postal code validation
    if (!(isUser && !isSupplier)) {
      bool validPin = await GoogleApis().isPostalCodeValid(postalCode);
      if (!validPin) {
        CommonWidgets.removeProgress();
        AjugnuFlushbar.showError(context, 'Postal code is invalid.');
        return;
      }
    }

    // ***********************
    //   MAIN SIGNUP CALL
    // ***********************
    AjugnuAuth()
        .signup(
      fullName,
      mobile,
      email,
      password,
      isUser && isSupplier ? 'both' : isUser ? 'user' : 'supplier',
      pinCodeController.text,
    )
        .then((otp) {
      CommonWidgets.removeProgress();

      // OTP Navigate Here
      AjugnuNavigations.verificationScreen(
        phoneNumber: mobile,
        email: email,
        otpSent: true,
        otp: otp, // <-- YAHI IMPORTANT HAI
      );

      AjugnuFlushbar.showSuccess(context, "OTP sent successfully");

    }).catchError((error) {
      CommonWidgets.removeProgress();

      if (error.toString().contains('java.io.IOException')) {
        AjugnuFlushbar.showError(
            context,
            "Service Not available.\nPlease check your network connection and try again");
      } else {
        AjugnuFlushbar.showError(context, error.toString());
      }
    });
  }
}