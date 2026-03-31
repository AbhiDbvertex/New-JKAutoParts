import 'dart:io';

import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/models/ajugnu_users.dart';
import 'package:jkautomed/users/common/backend/ajugnu_auth.dart';
import 'package:jkautomed/users/common/backend/api_handler.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:jkautomed/users/common/form_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../common/AjugnuFlushbar.dart';
import '../common/postal_pin_dialog.dart';

class SupplierEditProfileScreen extends StatefulWidget {
  const SupplierEditProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SupplierEditProfileState();
  }
}

class SupplierEditProfileState extends State<SupplierEditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  File? selectedProfileImage;
  List<String?> selectedPinCodes = [];

  AjugnuUser? user;

  String? location;

  @override
  void initState() {
    super.initState();
    user = AjugnuAuth().getUser();
    fullNameController.text = user?.fullName ?? '';
    // addressController.text = user?.address ?? '';
    for (var code in user?.pinCode ?? []) {
      if (code != null) {
        selectedPinCodes.add(code);
      }
    }
    Future.delayed(
        const Duration(milliseconds: 10),
        () => getCurrentLocation()
            .then((location) => setState(() => this.location = location)));
  }

  void pickImage() async {
    try {
      var image = await ImagePicker()
          .pickImage(imageQuality: 30, source: ImageSource.gallery);
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
    adebug(location, tag: 'build');
    return Scaffold(
      primary: true,
      backgroundColor: AjugnuTheme.appColor,
      extendBodyBehindAppBar: true,
      appBar: CommonWidgets.appbar("Edit Profile",
          color: Colors.white,
          systemUiOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light)),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/gradient_background.png'),
                    fit: BoxFit.cover)),
            padding: EdgeInsets.only(top: width * 0.23),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CommonWidgets.profileImagePicker(
                        selectedProfileImage?.path ?? user?.profilePic ?? '',
                        onPressed: () => pickImage()),
                  ),
                  SizedBox(height: width * 0.1),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08),
                    child: CommonWidgets.editbox(
                        cursorColor: Colors.white,
                        alignment: TextAlign.start,
                        maxLength: FormValidators.maxNameChunkLength,
                        hint: "Full Name",
                        controller: fullNameController,
                        keyboardType: TextInputType.name,
                        autofillHints: [AutofillHints.name]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(
                        cursorColor: Colors.white,
                        alignment: TextAlign.start,
                        maxLength: FormValidators.maxPhoneLength,
                        hint: "Mobile Number",
                        controller:
                            TextEditingController(text: "+91 ${user?.mobile}"),
                        enabled: false,
                        keyboardType: TextInputType.phone,
                        autofillHints: [AutofillHints.telephoneNumber]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(
                        cursorColor: Colors.white,
                        alignment: TextAlign.start,
                        hint: "Email Address",
                        controller: TextEditingController(text: user?.email),
                        enabled: false,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: [AutofillHints.email]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: CommonWidgets.editbox(
                        cursorColor: Colors.white,
                        alignment: TextAlign.start,
                        hint: "Enter Your Address",
                        controller: addressController,
                        keyboardType: TextInputType.text,
                        autofillHints: [AutofillHints.fullStreetAddress]),
                  ),
                  Visibility(
                    visible: addressController.text.trim().isEmpty &&
                        location != null,
                    child: GestureDetector(
                      onTap: () {
                        addressController.text = location ?? '';
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.08, right: width * 0.08, top: 6),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: Text.rich(TextSpan(
                                text: 'Suggestion: ',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Poly',
                                    fontSize: 12),
                                children: [
                                  TextSpan(
                                      text: location,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontFamily: 'Poly',
                                          fontSize: 12))
                                ]))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.08, right: width * 0.08, top: 16),
                    child: Card.outlined(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(
                                color: Colors.white70, width: 1)),
                        elevation: 0,
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 8),
                          title: (selectedPinCodes.isEmpty)
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 6),
                                  child: Text(
                                    "Add Pin Codes",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white70),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Wrap(
                                    children: selectedPinCodes
                                        .map((e) => Card.outlined(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(26),
                                                  side: const BorderSide(
                                                      color: Colors.white54)),
                                              color: Colors.black12,
                                              elevation: 0,
                                              clipBehavior: Clip.hardEdge,
                                              child: InkWell(
                                                onTap: () => setState(() {
                                                  selectedPinCodes.remove(e);
                                                }),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 6),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        e.toString(),
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.white,
                                                            fontFamily: 'Poly'),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      const Icon(Icons.close,
                                                          size: 16,
                                                          color: Colors.white)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                          trailing: IconButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                showPostalPinDialog(
                                    context, selectedPinCodes.cast(),
                                    (List<String> pins) {
                                  setState(() {
                                    selectedPinCodes.clear();
                                    selectedPinCodes.addAll(pins);
                                  });
                                });
                              });
                            },
                            icon: Container(
                              height: 26,
                              width: 26,
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(1000)),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1, vertical: width * 0.1),
                    child: ElevatedButton(
                      onPressed: () {
                        editProfile(
                            fullNameController.text.trim(),
                            addressController.text.trim(),
                            selectedProfileImage?.path,
                            selectedPinCodes);
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
                        'Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
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
    );
  }

  Future<void> editProfile(String fullName, String address, String? path,
      List<String?> pinCodes) async {
    String? fullNameError = FormValidators.isValidFullname(fullName);

    if (fullNameError == null) {
      String postalCode = '';
      try {
        var location = await locationFromAddress(address);
        adebug(location, tag: 'Getting location');

        if (location.isNotEmpty) {
          postalCode = (await placemarkFromCoordinates(
                      location.firstOrNull?.latitude ?? 0,
                      location.firstOrNull?.longitude ?? 0))
                  .firstOrNull
                  ?.postalCode ??
              '';
        }
      } catch (error) {
        adebug(error);
      }
      if (postalCode.isNotEmpty) {
        CommonWidgets.showProgress();
        AjugnuAuth()
            .editProfileSupplier(
                fullName, address, pinCodes, selectedProfileImage)
            .then((isSuccessful) {
          CommonWidgets.removeProgress();
          if (isSuccessful) {
            Navigator.pop(context);
            AjugnuFlushbar.showSuccess(
                context, 'Profile updated successfully.');
          }
        }, onError: (error) {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showError(
              context, 'Something went wrong while updating profile.');
        });
      } else {
        AjugnuFlushbar.showError(context, 'Please add valid address.');
      }
    } else {
      AjugnuFlushbar.showError(context, fullNameError);
    }
  }

  Future<String?> getCurrentLocation() async {
    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        Position? coordinates;
        if ((await Geolocator.checkPermission()) ==
                LocationPermission.whileInUse ||
            (await Geolocator.checkPermission()) == LocationPermission.always) {
          coordinates = await Geolocator.getCurrentPosition();
        } else {
          var permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse ||
              permission == LocationPermission.unableToDetermine) {
            coordinates = await Geolocator.getCurrentPosition();
          }
        }
        if (coordinates != null) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              coordinates.latitude, coordinates.longitude);
          if (placemarks.isNotEmpty) {
            Placemark placemark = placemarks.first;
            String address = [
              placemark.street,
              placemark.locality,
              placemark.subLocality,
              placemark.postalCode,
              placemark.country,
            ]
                .where((element) => element != null && element.isNotEmpty)
                .join(', ');
            adebug(address, tag: 'Location');
            return address;
          }
        }
      }
    } catch (e) {
      // Ignore
      adebug(e.toString(), tag: 'getting location');
    }
    return null;
  }
}
