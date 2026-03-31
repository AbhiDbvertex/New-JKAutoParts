 import 'dart:convert';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jkautomed/users/customer/product_change_listeners.dart';

import '../../models/ajugnu_product.dart';
import '../common/AjugnuFlushbar.dart';
import '../common/backend/ajugnu_auth.dart';
import '../common/backend/api_handler.dart';
import '../common/common_widgets.dart';

class CustomerRatingScreen extends StatefulWidget {
  final String productId;

  const CustomerRatingScreen({super.key, required this.productId});

  @override
  State<StatefulWidget> createState() {
    return CustomerRatingState();
  }
}

class CustomerRatingState extends State<CustomerRatingScreen> {
  final messageController = TextEditingController();

  double rating = 0;

  @override
  Widget build(BuildContext context) {

    ColorScheme colorScheme = Theme.of(context)
        .colorScheme;
    TextStyle hintStyle = TextStyle(
        color: colorScheme.inverseSurface, fontSize: 14,
        fontWeight: FontWeight.w500
    );
    TextStyle labelStyle = TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500
    );
    double width = MediaQuery.of(context).size.width;
    const double fieldPadding = 15;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CommonWidgets.appbar('Give Us Rating'),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Image(
                      image: const AssetImage('assets/images/rating_image.png'),
                      height: width * 0.48,
                      width: width * 0.7,
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.06),
                    color: colorScheme.onPrimary,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.08),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: width * 0.07, left: width * 0.1, right: width * 0.1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(alignment: Alignment.center, child: Text(
                                      'Share your experience with us',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    )),
                                    const SizedBox(height: 5),
                                    RatingBar(
                                        size: width * 0.122,
                                        alignment: Alignment.center,
                                        maxRating: 5,
                                        filledIcon: Icons.star_rounded,
                                        emptyIcon: Icons.star_rounded,
                                        onRatingChanged: (rating) {
                                          this.rating = rating;
                                        }
                                    ),
                                  ],
                                ),
                              ),
                              TextField(
                                  controller: messageController,
                                  keyboardType: TextInputType.multiline,
                                  style: labelStyle,
                                  minLines: 6,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                      hintText: 'Type review about your experience',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: BorderSide(color: colorScheme.inversePrimary)
                                      ),
                                      hintStyle: hintStyle,
                                      contentPadding: const EdgeInsets.all(fieldPadding * 1.5)
                                  )
                              ),
                              const SizedBox(height: fieldPadding * 2),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xff040A05),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              side: BorderSide(color: Color(0xffABFFE7), width: 1)
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 30),
                                            elevation: 5
                                        ),
                                        onPressed: () {
                                          submit();
                                        },
                                        child: const Text(
                                            'Submit',
                                            style: TextStyle(color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)
                                        )
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                                side: const BorderSide(color: Color(0xffABFFE7), width: 1)
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 30),
                                            elevation: 5
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)
                                        )
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
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

  void submit() {
    var message = messageController.text.trim();
    if (message.isNotEmpty) {
      CommonWidgets.showProgress();
      makeHttpPostRequest(endpoint: "/api/user/addRating", bodyJson: jsonEncode({
        "product_id" : widget.productId,
        "rating" : rating,
        "message" : message
      }), authorization: AjugnuAuth().getUser()?.token??'').then((response) {
        CommonWidgets.removeProgress();
        if (response.statusCode == 201) {
          ProductChangeListeners.broadcastChanges(AjugnuProduct(id: widget.productId, productName: 'productName', weight: '0kg', averageRating: 0, ratingCount: 0, productImages: [], localName: 'localName', otherName: 'otherName', categoryId: 'categoryId', price: 0, quantity: 0, productType: 'productType', productSize: 'productSize', productRole: 'productRole', description: 'description', supplierId: 'supplierId', createdAt: DateTime.now(), updatedAt: DateTime.now(), isApproved: true, isFavourite: false, isRated: true), completeProduct: false);
          Navigator.of(context).pop();
          AjugnuFlushbar.showSuccess(context, 'Review posted');
        } else {
          AjugnuFlushbar.showError(context, response.responseBody.containsKey('message')
              ? response.responseBody['message']
              : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
              ? response.responseBody['msg']
              : 'Something went wrong. (response code: ${response.statusCode})');
        }
      }, onError: (error) {
        CommonWidgets.removeProgress();
        AjugnuFlushbar.showError(context, error.toString());
      });
    } else {
      AjugnuFlushbar.showError(context, 'Please enter message.');
    }
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }
}