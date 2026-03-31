import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/ajugnu_navigations.dart';
import 'package:jkautomed/users/common/AjugnuFlushbar.dart';
import 'package:jkautomed/users/common/backend/google_apis.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:jkautomed/users/common/backend/ajugnu_auth.dart';
import 'package:jkautomed/users/common/form_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AddBankDetailsScreen extends StatefulWidget {
  const AddBankDetailsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddBankDetailsState();
  }
}

class AddBankDetailsState extends State<AddBankDetailsScreen> {
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifciNumberController = TextEditingController();
  final bankAddressController = TextEditingController();
  final yourNameInBankController = TextEditingController();



  @override
  void dispose() {
    super.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifciNumberController.dispose();
    bankAddressController.dispose();
    yourNameInBankController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      primary: true,
      backgroundColor: AjugnuTheme.appColor,
      extendBodyBehindAppBar: true,
      appBar: CommonWidgets.appbar("Bank Details",
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
            padding: EdgeInsets.only(top: width * 0.24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: width * 0.01),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image:
                      AssetImage('assets/images/bank_details_logo.png'),
                      height: 175,
                      width: 178,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: width * 0.01),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08),
                    child: CommonWidgets.editbox(
                        alignment: TextAlign.start,
                        hint: "Bank Name",
                        maxLength: FormValidators.maxNameChunkLength,
                        controller: bankNameController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(
                        alignment: TextAlign.start,
                        hint: "Account Number",
                        maxLength: 17,
                        controller: accountNumberController,
                        keyboardType: TextInputType.number
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(
                        alignment: TextAlign.start,
                        hint: "IFSC Number",
                        maxLength: 11,
                        controller: ifciNumberController,
                        keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: width * 0.08, right: width * 0.08, top: 16),
                      child: CommonWidgets.editbox(
                          alignment: TextAlign.start,
                          hint: "Bank Address",
                          controller: bankAddressController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(
                        alignment: TextAlign.start,
                      hint: "Your Name In Bank",
                      maxLength: FormValidators.maxNameChunkLength,
                      controller: yourNameInBankController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words
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

  void submit() async {
    String bankName = bankNameController.text.trim();
    String accountNumber = accountNumberController.text.trim();
    String ifscNumber = ifciNumberController.text.trim();
    String bankAddress = bankAddressController.text.trim();
    String username = yourNameInBankController.text.trim();

    String? validationError = await validate(bankName, accountNumber, ifscNumber, bankAddress, username);

    if (validationError != null) {
      AjugnuFlushbar.showError(context, validationError);
      return;
    }

    CommonWidgets.showProgress();
    AjugnuAuth().addBankDetails(bankName, accountNumber, ifscNumber, bankAddress, username).then((message) {
      CommonWidgets.removeProgress();
      Navigator.of(context).pop();
      AjugnuFlushbar.showSuccess(context, message);
    }, onError: (error) {
      CommonWidgets.removeProgress();
      AjugnuFlushbar.showError(context, (error ?? 'Something went wrong.').toString());
    });
  }

  Future<String?> validate(String bankName, String accountNumber, String ifscNumber, String address, String yourName) async {
    if (bankName.isEmpty) {
      return 'Please enter bank name.';
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(bankName)) {
      return 'Bank name cannot contain numbers or special symbols, please enter the correct name.';
    } else if (!RegExp(r'^\d{10,17}$').hasMatch(accountNumber)) { // Example: 10-12 digits
      return 'Account number must be 10 to 17 digits.';
    } else if (accountNumber.isEmpty) {
      return 'Please enter account number.';
    }else if (ifscNumber.isEmpty) {
      return 'Please enter IFSC number.';
    } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscNumber)) { // IFSC format example
      return 'IFSC number is invalid. Please enter a valid IFSC.';
    } else if (address.isEmpty) {
      return 'Please enter your address.';
    } else if (address.length < 10) { // Example: Minimum length
      return 'Address must be at least 10 characters long.';
    } else if (yourName.isEmpty) {
      return 'Please enter your name.';
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(yourName)) {
      return 'Your name cannot contain numbers or special symbols, please enter your correct name.';
    }

    // GoogleApis().
    return null;
  }


}
