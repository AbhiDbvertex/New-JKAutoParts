import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/ajugnu_navigations.dart';
import 'package:jkautomed/main.dart';
import 'package:jkautomed/models/ajugnu_type.dart';
import 'package:jkautomed/models/ajugnu_users.dart';
import 'package:jkautomed/users/common/AjugnuFlushbar.dart';
import 'package:jkautomed/users/common/backend/category_repository.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:jkautomed/users/common/backend/ajugnu_auth.dart';
import 'package:jkautomed/users/customer/backend/customer_product_repository.dart';
import 'package:jkautomed/users/supplier/backend/product_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../common/backend/api_handler.dart';

class SupplierAddProductScreen extends StatefulWidget {

  const SupplierAddProductScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SupplierAddProductState();
  }

}

class SupplierAddProductState extends State<SupplierAddProductScreen> {
  final TextEditingController englishController = TextEditingController();
  final TextEditingController localController = TextEditingController();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? _selectedType;
  String? _selectedSize;
  String? categoryId;
  final List<File> selectedPhotos = <File>[];
  List<Map<String, String>> categories = [];
  List<AjugnuType> types = [];

  Future<void> getCategories() async {
    if (CategoryRepository().doesCategoriesAvailableLocally()) {
       setState(() {
         categories = CategoryRepository().allCategories!;
       });
       CommonWidgets.showProgress();
       CustomerProductRepository().getTypes().then((type) {
         CommonWidgets.removeProgress();
         setState(() {
           types = type;
         });
       }, onError: (error) {
         CommonWidgets.removeProgress();
         AjugnuFlushbar.showError(context, error.toString());
       });
    } else {
      CommonWidgets.showProgress();
      try {
        var temp = await CategoryRepository().getCategories();
        setState(() {
          categories = temp;
        });
        CustomerProductRepository().getTypes().then((type) {
          CommonWidgets.removeProgress();
          setState(() {
            types = type;
          });
        }, onError: (error) {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showError(context, error.toString());
        });
      } catch (error) {
        // nothing
        adebug(error);
        CommonWidgets.removeProgress();
        AjugnuFlushbar.showError(context, error.toString());
      }
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0), () => getCategories());
    super.initState();
  }

  @override
  void dispose() {
    englishController.dispose();
    localController.dispose();
    otherController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
        appBar: CommonWidgets.appbar(
          "Add Product",
          systemUiOverlayStyle: SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              statusBarColor: AjugnuTheme.appColorScheme.onPrimary,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.dark
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(color: Colors.black12, height: 1, width: width),
              Container(
                color: Colors.black12,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 12),
                      child: CommonWidgets.text('Product Name', fontSize: 15),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                      child: editbox(hint: 'English Name', maxLength: 50, controller: englishController, textCapitalization: TextCapitalization.words),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                      child: editbox(hint: 'Local Name', maxLength: 50, controller: localController, textCapitalization: TextCapitalization.words),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                      child: editbox(hint: 'Other Name', maxLength: 50, controller: otherController, textCapitalization: TextCapitalization.words),
                    ),
                    const SizedBox(height: 28,)
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: editbox(label: 'Price', maxLength: 7, keyboardType: TextInputType.number, controller: priceController, textCapitalization: TextCapitalization.words),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: editbox(label: 'Quantity', maxLength: 7, keyboardType: TextInputType.number, controller: quantityController, textCapitalization: TextCapitalization.words),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: dropdown(hint: 'Select Product Category', data: categories.map<String>((e) => e['name'] ?? '').toList(), onChanged: (value) {
                  for (var cat in categories) {
                    if (cat['name'] == value) {
                      categoryId = cat['_id'];
                    }
                  }
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: dropdown(hint: 'Select Product Type', data: types.map((type) => type.name).toList(), onChanged: (value) {
                  _selectedType = value;
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: dropdown(hint: 'Select Product Size', data: ['small', 'medium', 'large'], onChanged: (value) {
                  _selectedSize = value;
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: editbox(label: 'Description', maxLength: 200, maxLines: 4, controller: descriptionController, textCapitalization: TextCapitalization.sentences),
              ),

              const SizedBox(height: 16),
              Container(
                color: Colors.black12,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 12, left: 26),
                      child: CommonWidgets.text('Product Photos', fontSize: 15),
                    ),
                    SizedBox(
                      height: width * 0.28,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if (index == selectedPhotos.length) {
                            return Container(
                              width: index == 0 ? width * 0.38 : width * 0.32,
                              padding: EdgeInsets.only(left: index == 0 ? 18 : 0, right: 8, top: 8, bottom: 8),
                              child: InkWell(
                                onTap: () {
                                  pickImage();
                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset('assets/icons/icon_add_product_photo.png', width: width * 0.3, height: width * 0.3),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: index == 0 ? width * 0.38 : width * 0.32,
                            padding: EdgeInsets.only(left: index == 0 ? 18 : 0, right: 8, top: 8, bottom: 8),
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Center(
                                      child: Image.file(selectedPhotos[index], width: width * 0.3, height: width * 0.3, fit: BoxFit.cover)
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: index == 0 ? width * 0.2 : width * 0.19,
                                  child: Card(
                                      color: AjugnuTheme.appColorScheme.onPrimary.withOpacity(0.29),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1000)
                                      ),
                                      elevation: 0,
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        onTap: () => setState(() {
                                          selectedPhotos.removeAt(index);
                                        }),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Icon(Icons.close, size: 14),
                                          // child: Image(image: AssetImage("assets/icons/icon_camera.png"), fit: BoxFit.cover, height: 14, width: 14),
                                        ),
                                      )
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        itemCount: selectedPhotos.length + 1,
                      ),
                    ),
                    const SizedBox(height: 12)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 16),
                child: ElevatedButton(
                  onPressed: () => add(),
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
                    "Save And Publish",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 58)
            ],
          ),
        )
    );
  }

  static TextField editbox({TextEditingController? controller, int? maxLength, int maxLines = 1, String? hint, String? label, TextCapitalization textCapitalization = TextCapitalization.words, TextInputType keyboardType = TextInputType.text, obscureText = false, List<String> autofillHints = const []}) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          fontFamily: 'Poly',
          color: Colors.black
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.start,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        labelText: label,
        filled: true,
        fillColor: AjugnuTheme.appColorScheme.onPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        hintStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poly',
            color: Colors.black26
        ),
        labelStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poly',
            color: Colors.black26
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black12, width: 2)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black12, width: 1.2)
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16)
        ),
      ),

    );
  }

  static DropdownButtonFormField dropdown({TextEditingController? controller, String? hint, List<String> data = const [], required Function(dynamic) onChanged}) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AjugnuTheme.appColorScheme.onPrimary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          hintStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              fontFamily: 'Poly',
              color: Colors.black26
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black12, width: 1)
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black12, width: 1)
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16)
          ),
        ),
        value: null,
        items: data.map((val) => DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poly',
            color: Colors.black
        )))).toList(),
        onChanged: onChanged
    );
  }

  void pickImage() async {
    if (selectedPhotos.length > 2) {
      AjugnuFlushbar.showError(context, 'Can not add more than 3 images per product. Please consider removing some images and then try to add new one.');
      return;
    }
    // if (selectedPhotos.length < 1) {
    //   AjugnuFlushbar.showError(context, 'Add at-least one image of product');
    //   return;
    // }
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(bottom: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.12, vertical: 20),
              child: CommonWidgets.text('Choose images from'),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        var image = await ImagePicker().pickImage(source: ImageSource.camera);
                        setState(() {
                          selectedPhotos.add(File(image!.path));
                        });
                        adebug(selectedPhotos, tag: 'pickImage');
                      } catch (e) {
                        if (kDebugMode) {
                          print("ishwar:temp while picking images: $e");
                        }
                        AjugnuFlushbar.showError(getAjungnuGlobalContext(), 'Error while picking images.');
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 228, 244, 214,),
                            borderRadius: BorderRadius.circular(1000)
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset('assets/images/photo_source_camera.png', ),
                        ),
                        const SizedBox(height: 8),
                        CommonWidgets.text('Camera')
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        var image = await ImagePicker().pickMultiImage();
                        setState(() {
                          selectedPhotos.addAll(image.map((e) => File(e.path)).toList().getRange(0, min(3 - selectedPhotos.length, image.length)));
                        });
                        adebug(selectedPhotos, tag: 'pickImage');
                      } catch (e) {
                        if (kDebugMode) {
                          print("ishwar:temp while picking images: $e");
                        }
                        AjugnuFlushbar.showError(getAjungnuGlobalContext(), 'Error while picking images.');
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 228, 244, 214,),
                              borderRadius: BorderRadius.circular(1000)
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset('assets/images/photo_source_gallery.png', ),
                        ),
                        const SizedBox(height: 8),
                        CommonWidgets.text('Gallery')
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
  void add() async {
    var englishName = englishController.text.trim();
    var localName = localController.text.trim();
    var otherName = otherController.text.trim();
    int price = priceController.text.trim().isNotEmpty ? int.tryParse(priceController.text.trim())??0 : 0;
    int quantity = quantityController.text.trim().isNotEmpty ? int.tryParse(quantityController.text.trim())??0 : 0;
    var description = descriptionController.text.trim();
    if (selectedPhotos.isEmpty || selectedPhotos.length<1) {
      AjugnuFlushbar.showError(context, 'Please add at least one product photo.');
      return;
    }
    if (englishName.isNotEmpty && RegExp(r"^[a-zA-Z ]+$").hasMatch(englishName)) {
      if (localName.isNotEmpty) {
        if (otherName.isNotEmpty) {
          if (priceController.text.trim().isNotEmpty) {
            if (price > 0 && price <= 10000000) {  // Price condition
              if (categoryId != null) {
                if (quantityController.text.trim().isNotEmpty) {
                  if (quantity > 0 && quantity <= 10000000) {  // Quantity condition
                    if (_selectedType != null) {
                      if (_selectedSize != null) {
                        if (description.isNotEmpty) {
                          if (description.length >= 10 && description.length <= 200) {  // Description length condition
                            CommonWidgets.showProgress();
                            ProductRepository().addProduct(
                              englishName,
                              localName,
                              otherName,
                              categoryId!,
                              price.toString(),
                              quantity.toString(),
                              _selectedType!,
                              _selectedSize!,
                              description,
                              selectedPhotos.map((e) => e.path).toList(),
                            ).then((status) {
                              CommonWidgets.removeProgress();
                              if (status) {
                                AjugnuNavigations.supplierHomeScreen(type: AjugnuNavigations.typeRemoveAllAndPush);
                                AjugnuFlushbar.showSuccess(context, 'Your product successfully added.');
                              } else {
                                AjugnuFlushbar.showError(context, 'We are facing some issues while adding your product, please try again later. If the issue persists, contact our support team.');
                              }
                            }, onError: (error) {
                              CommonWidgets.removeProgress();
                              AjugnuFlushbar.showError(context, error.toString());
                            });
                          } else {
                            AjugnuFlushbar.showError(context, 'Description should be between 10 and 200 characters.');
                          }
                        } else {
                          AjugnuFlushbar.showError(context, 'Please add a description of your product.');
                        }
                      } else {
                        AjugnuFlushbar.showError(context, 'Please specify the size category of your product.');
                      }
                    } else {
                      AjugnuFlushbar.showError(context, 'Please select the product type.');
                    }
                  } else {
                    AjugnuFlushbar.showError(context, 'Quantity should be a round number and between 1 and 1 crore.');
                  }
                } else {
                  AjugnuFlushbar.showError(context, 'Please enter a valid quantity.');
                }
              } else {
                AjugnuFlushbar.showError(context, 'Please select a product category.');
              }
            } else {
              AjugnuFlushbar.showError(context, 'Price should be a round number and between 0 and 1 crore.');
            }
          } else {
            AjugnuFlushbar.showError(context, 'Please enter a price for the product.');
          }
        } else {
          AjugnuFlushbar.showError(context, 'Please enter another name for the product.');
        }
      } else {
        AjugnuFlushbar.showError(context, 'Please enter a valid local name for the product.');
      }
    } else {
      AjugnuFlushbar.showError(context, 'Please enter a valid English name for the product. Name must contain only a-z and A-Z.');
    }
  }

}