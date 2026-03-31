import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:jkautomed/users/common/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
      appBar: CommonWidgets.appbar('', systemUiOverlayStyle: SystemUiOverlayStyle(systemNavigationBarColor: AjugnuTheme.appColorScheme.onPrimary, systemNavigationBarIconBrightness: Brightness.dark)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/bags.png', width: MediaQuery.of(context).size.width * 0.7, height: MediaQuery.of(context).size.width * 0.7),
              SizedBox(height: MediaQuery.of(context).size.width * 0.15),
              CommonWidgets.text('Success!', fontSize: 26),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.12),
                child: CommonWidgets.text('Your order will be delivered soon. Thank you for choosing our app!', fontSize: 17, fontFamily: 'Poly', alignment: TextAlign.center),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.2),
              Padding(padding: EdgeInsets.symmetric(horizontal: 60),
              child: ElevatedButton(
                style: ButtonStyle(
                    elevation:
                    const WidgetStatePropertyAll<double>(0),
                    backgroundColor:
                    const WidgetStatePropertyAll<Color>(
                        Color(0xff040A05)),
                    side: const WidgetStatePropertyAll<
                        BorderSide>(
                        BorderSide(color: Color(0xffABFFE7))),
                    shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10)))),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 26),
                    child: CommonWidgets.text('OK',
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        fontFamily: 'Aclonica',
                        textColor: Colors.white),
                  ),
                ),
                onPressed:() => Navigator.of(context).pop()
                ),

              )
            ],
          ),
        ),
      ),
    );
  }


}