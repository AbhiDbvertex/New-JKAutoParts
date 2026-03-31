import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;

import '../../ajugnu_constants.dart';
import 'backend/api_handler.dart';
import 'common_widgets.dart';

class InformationScreen extends StatefulWidget {

  static const titlePrivacyPolicy = 'Privacy Policy';
  static const titleT_C = 'Terms & Condition';
  static const titleAboutUs = 'About Us';

  String title;

  InformationScreen(this.title, {super.key});

  @override
  State<StatefulWidget> createState() {
    return InformationPageState();
  }
}

class InformationPageState extends State<InformationScreen>{
  String? content;

  Future<String> fetchContent() async {
    String api = widget.title == InformationScreen.titlePrivacyPolicy ? 'getPrivacyPolicy' : widget.title == InformationScreen.titleAboutUs ? 'getAboutUs' : widget.title == InformationScreen.titleT_C ? 'getTermsConditions' : '';
    ApiResponse response = await makeHttpGetRequest(endpoint: "/api/CompanyDetails/$api");
    return response.responseBody['content'] ?? response.responseBody['message'] ?? 'Something went wrong.';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (content == null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        CommonWidgets.showProgress();
        fetchContent().then((message) {
          CommonWidgets.removeProgress();
          setState(() {
            content = message;
          });
        }, onError: (error) {
          CommonWidgets.removeProgress();
          setState(() {
            content = error.toString();
          });
        });
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double topImageHeight = width * 0.8;
    double topImageWidth = width * 0.7;

    return Scaffold(
      backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
      appBar: AppBar(
          title: CommonWidgets.appbar(widget.title),
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: false,
              floating: true,
              expandedHeight: topImageHeight,
              backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Image(
                    image: AssetImage(widget.title == InformationScreen.titlePrivacyPolicy ? 'assets/images/privacy_logo.png' : widget.title == InformationScreen.titleAboutUs ? 'assets/images/about_us_logo.png' : 'assets/images/terms_logo.png'),
                    height: topImageHeight,
                    width: topImageWidth,
                  ),
                ),
              ),
            )
          ];
        },
        body: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40))
          ),
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          margin: EdgeInsets.zero,
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.04, horizontal: width * 0.06),
                child: content == null ? const Text('Fetching...', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)) : HtmlWidget(content!, textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
            ),
          ),
        ),
      ),
    );
  }
}