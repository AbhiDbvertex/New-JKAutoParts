
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ajugnu_constants.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'common_widgets.dart';
import 'form_validator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();

  bool obscureText1 = true;
  bool obscureText2 = true;

  @override
  void dispose() {
    super.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    cPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      primary: true,
      // backgroundColor: AjugnuTheme.appColor,
      extendBodyBehindAppBar: true,
      appBar: CommonWidgets.appbar("Change Password",
          color: Colors.white,
          systemUiOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light
          )
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/gradient_background.png'),
                    fit: BoxFit.cover)
            ),
            padding: EdgeInsets.only(top: width * 0.23),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: width * 0.05),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image:
                          AssetImage('assets/images/change_password_logo.png'),
                      height: 175,
                      width: 178,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: width * 0.05),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, 
                        alignment: TextAlign.start,
                        maxLength: FormValidators.maxPasswordLength,
                        hint: "Enter Old Password",
                        controller: oldPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: [AutofillHints.password]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, 
                        alignment: TextAlign.start,
                        hint: "Enter New Password",
                        maxLength: FormValidators.maxPasswordLength,
                        obscureText: obscureText1,
                        suffix: obscureText1?Icons.visibility_off:Icons.visibility,
                        controller: newPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: [AutofillHints.newPassword],
                        onTapIcon: () {
                          setState(() {
                            obscureText1 = !obscureText1;
                          });
                        }
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(cursorColor: Colors.white, 
                        alignment: TextAlign.start,
                        hint: "Confirm New Password",
                        maxLength: FormValidators.maxPasswordLength,
                        obscureText: obscureText2,
                        suffix: obscureText2?Icons.visibility_off:Icons.visibility,
                        controller: cPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: [AutofillHints.newPassword],
                        onTapIcon: () {
                  setState(() {
                  obscureText2 = !obscureText2;
                  });
                  }
                  ),

                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1, vertical: width * 0.1),
                    child: Row(
                      children: [
                        Card.outlined(
                          elevation: 0,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 121, 255, 217))),
                          child: InkWell(
                            onTap: () {
                              submit();
                            },
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Card.outlined(
                          elevation: 0,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 121, 255, 217))),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  void submit() {
    var oldPassword = oldPasswordController.text.trim();
    var newPassword = newPasswordController.text.trim();
    var confirmPassword = cPasswordController.text.trim();

    String? oldPasswordError = FormValidators.isValidPassword(oldPassword);
    String? newPasswordError = FormValidators.isValidPassword(newPassword);

    if (oldPasswordError == null) {
      if (newPasswordError == null) {
        if (newPassword == confirmPassword) {
          CommonWidgets.showProgress();
          AjugnuAuth().changePassword(oldPassword, newPassword, confirmPassword).then((message) {
            CommonWidgets.removeProgress();
            if (message.status) {
              Navigator.of(context).pop();
              AjugnuFlushbar.showSuccess(context, message.message ?? 'Password changed successfully.');
            } else {
              AjugnuFlushbar.showError(context, message.message ?? 'Something went wrong while updating password.');
            }
          }, onError: (error) {
            CommonWidgets.removeProgress();
            AjugnuFlushbar.showError(context, (error ?? 'Something went wrong.').toString());
          });
        } else {
          AjugnuFlushbar.showError(context, "Password doesn't match.");
        }
      } else {
        AjugnuFlushbar.showError(context, "New ${newPasswordError.toLowerCase()}");
      }
    } else {
      AjugnuFlushbar.showError(context, "Old ${oldPasswordError.toLowerCase()}");
    }
  }
}
