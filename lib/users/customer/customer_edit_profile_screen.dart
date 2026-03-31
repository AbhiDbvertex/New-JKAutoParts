import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import '../../ajugnu_constants.dart';
import '../../models/ajugnu_users.dart';
import '../common/AjugnuFlushbar.dart';
import '../common/backend/ajugnu_auth.dart';
import '../common/backend/api_handler.dart';
import '../common/common_widgets.dart';
import '../common/form_validator.dart';
import '../common/postal_pin_dialog.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomerEditProfileState();
  }

}

class CustomerEditProfileState extends State<CustomerEditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  File? selectedProfileImage;

  AjugnuUser? user;

  // @override
  // void initState() {
  //   super.initState();
  //   user = AjugnuAuth().getUser();
  //   fullNameController.text = user?.fullName??'';
  //   addressController.text = user?.addressMap??'';
  // }

  @override
  void initState() {
    super.initState();
    user = AjugnuAuth().getUser();

    fullNameController.text = user?.fullName ?? '';

    // ✅ Address Map se readable string bana rahe hain
    if (user?.addressMap != null) {
      final addr = user!.addressMap!;
      final List<String> parts = [];

      if (addr['building_name'] != null && addr['building_name'].toString().isNotEmpty) {
        parts.add(addr['building_name']);
      }
      if (addr['address_line'] != null && addr['address_line'].toString().isNotEmpty) {
        parts.add(addr['address_line']);
      }
      if (addr['address_description'] != null && addr['address_description'].toString().isNotEmpty) {
        parts.add(addr['address_description']);
      }
      if (addr['city'] != null && addr['city'].toString().isNotEmpty) {
        parts.add(addr['city']);
      }
      if (addr['state'] != null && addr['state'].toString().isNotEmpty) {
        parts.add(addr['state']);
      }

      addressController.text = parts.isEmpty ? '' : parts.join(', ');
    } else {
      addressController.text = '';
    }
  }

  void pickImage() async {
    try {
      var image = await ImagePicker().pickImage(imageQuality: 30, source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedProfileImage = File(image.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        adebug(e.toString(), tag: 'pickImage');
      }
      // AjugnuFlushbar.showError(getAjungnuGlobalContext(), 'Error while picking images.');
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();



    addressController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        primary: true,
        backgroundColor: AjugnuTheme.appColor,
        extendBodyBehindAppBar: true,

        appBar: CommonWidgets.appbar("Edit Profile", color: Colors.white, systemUiOverlayStyle: const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light
        )),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/gradient_background.png'), fit: BoxFit.cover)
              ),
              padding: EdgeInsets.only(top: width * 0.23),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CommonWidgets.profileImagePicker(selectedProfileImage?.path??user?.profilePic??'', onPressed: () => pickImage()),
                    ),
                    SizedBox(height: width * 0.1),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08),
                      child: CommonWidgets.editbox(cursorColor: Colors.black, alignment: TextAlign.start, maxLength: FormValidators.maxNameChunkLength,  hint: "Full Name", controller: fullNameController, keyboardType: TextInputType.name, autofillHints: [AutofillHints.name]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 16),
                      child: CommonWidgets.editbox(cursorColor: Colors.black, alignment: TextAlign.start, maxLength: FormValidators.maxPhoneLength, hint: "Mobile Number", controller: TextEditingController(text: "+91 ${user?.mobile}"), enabled: false, keyboardType: TextInputType.phone, autofillHints: [AutofillHints.telephoneNumber]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 16),
                      child: CommonWidgets.editbox(cursorColor: Colors.black, alignment: TextAlign.start, hint: "Email Address", controller: TextEditingController(text: user?.email), enabled: false, keyboardType: TextInputType.emailAddress, autofillHints: [AutofillHints.email]),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: 16),
                    //   child: CommonWidgets.editbox(cursorColor: Colors.black, alignment: TextAlign.start, color: Colors.black, hint: "Enter Your Address", controller: addressController, keyboardType: TextInputType.text, autofillHints: [AutofillHints.fullStreetAddress]),
                    // ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: width * 0.1),
                      child: ElevatedButton(
                        onPressed: () {
                          editProfile(fullNameController.text.trim(), addressController.text.trim(), selectedProfileImage?.path);
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> editProfile(String fullName, String address, String? path) async {
    String? fullNameError = FormValidators.isValidFullname(fullName);

    if (fullNameError == null) {
      if (address.isNotEmpty) {
        CommonWidgets.showProgress();
        String postalCode = '';
        try {
          var location = await locationFromAddress(address);
          adebug(location, tag: 'Getting location');

          if (location.isNotEmpty) {
            postalCode = (await placemarkFromCoordinates(location.firstOrNull?.latitude??0, location.firstOrNull?.longitude??0)).firstOrNull?.postalCode??'';
          }
        } catch (error) {
          adebug(error);
        }
        if (postalCode.isNotEmpty) {
          AjugnuAuth().editProfileCustomer(fullName,/* address,*/ selectedProfileImage?.path).then((isSuccessful) {
            CommonWidgets.removeProgress();
            if (isSuccessful) {
              Navigator.pop(context);
              AjugnuFlushbar.showSuccess(context, 'Profile updated successfully.');
            }
          }, onError: (error) {
            CommonWidgets.removeProgress();
            AjugnuFlushbar.showError(context, 'Something went wrong while updating profile.');
          });
        } /*else {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showError(context, 'Please enter a valid address.');
        }*/
      } /*else {
        AjugnuFlushbar.showError(context, 'Please add your address.');
      }*/
    } else {
      AjugnuFlushbar.showError(context, fullNameError);
    }
  }
}