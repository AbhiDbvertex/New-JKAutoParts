import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../main.dart';
import '../../models/ajugnu_product.dart';

class CommonWidgets {

  static bool isProgressBarVisible = false;

  static void showQR(AjugnuProduct product, {bool showAction = true}) {
    showDialog(context: getAjungnuGlobalContext(), builder: (context) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
              margin: EdgeInsets.zero,
              color: AjugnuTheme.secondery,
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 18, right: 8, left: 25),
                    child: Row(
                      children: [
                        Expanded(child: text(product.productName, alignment: TextAlign.start, fontSize: 16)),
                        IconButton(onPressed: () {
                          Navigator.of(getAjungnuGlobalContext()).pop();
                        }, icon: Icon(Icons.close))
                      ],
                    ),
                  ),
                  QrImageView(
                    data: jsonEncode({
                      'name': product.productName,
                      '_id': product.id,
                      'supplier_id': product.supplierId
                    }),
                    version: QrVersions.auto,
                    size: MediaQuery.of(getAjungnuGlobalContext()).size.width * 0.7,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(25.0),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: text("Scan with Ajugnu in your friend's device to share.", textColor: Colors.grey, fontFamily: 'Roboto', fontSize: 12.5, alignment: TextAlign.center)
                  ),
                  Visibility(
                    visible: showAction,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AjugnuNavigations.supplierItemDetailScreen(product: product);
                        },
                        icon: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AjugnuTheme.appColorScheme.surface
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              text('View Product', alignment: TextAlign.center, fontSize: 14),
                              const Icon(Icons.arrow_right)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: showAction ? 10 : 18)
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

/*  static Widget profileImagePicker(String imageUrl, {required void Function() onPressed}) {
    return Center(
      child: SizedBox(
        height: 120,
        width: 120,
        child: Stack(
          children: [
            Center(
              child: IconButton(
                onPressed: () => onPressed(),
                icon: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.black38,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000)
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: imageUrl.startsWith('/') ? Image.file(
                    File(imageUrl),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ) : CachedNetworkImage(
                    height: 120,
                    width: 120,
                    imageUrl: imageUrl,
                    placeholderFadeInDuration: Duration.zero,
                    fit: BoxFit.cover,
                    placeholder: (context, error) => Container(color: Colors.black12,),
                    errorWidget: (context, url, error) => const Image(image: AssetImage("assets/images/profile_placeholder.png"), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              left: 82,
              child: Card(
                  color: AjugnuTheme.appColorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000)
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () => onPressed(),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Image(image: AssetImage("assets/icons/icon_camera.png"), fit: BoxFit.cover, height: 16, width: 16),
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }*/

  static Widget profileImagePicker(
      String imageUrl, {
        required VoidCallback onPressed,
      }) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onPressed,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF0D048C),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: imageUrl.startsWith('/')
                    ? Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                )
                    : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.black12),
                  errorWidget: (context, url, error) =>
                  const Image(
                    image: AssetImage(
                        "assets/images/profile_placeholder.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          /// camera icon
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  static TextField editbox({TextAlign alignment = TextAlign.center, Color? cursorColor, bool enabled = true, TextCapitalization textCapitalization = TextCapitalization.none, IconData? suffix, Function? onTapIcon,TextEditingController? controller, String? hint, TextInputType keyboardType = TextInputType.text, obscureText = false, List<String> autofillHints = const [], Function()? onEditingComplete, double borderSideWidth = 1.2, double focusedBorderSideWidth = 2, Color borderColor = Colors.white, double borderRadius = 8, Color color = Colors.white, String fontFamily = "Aclonica", double fontSize = 15, int? maxLength, String? label}) {
    return TextField(
      controller: controller,
      style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: color,
        fontFamily: fontFamily
      ),
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: TextInputAction.next,
      textAlign: alignment,
      textCapitalization: textCapitalization,
      cursorColor: cursorColor,
      cursorRadius: const Radius.circular(1000),
      onEditingComplete: onEditingComplete,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: color,
            fontFamily: fontFamily

        ),
        suffixIcon: suffix == null ? null : InkWell(
          onTap: (){
            onTapIcon!();
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1000)
              ),
              child: Icon(suffix, color: Colors.black, size: 18),
            ),
          ),
        ),
        labelText: label,
        labelStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: color,
            fontFamily: fontFamily
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: focusedBorderSideWidth)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: borderSideWidth)
        ),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: borderSideWidth)
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius)
        ),
      ),

    );
  }

  static Text text(String content, {String? fontFamily = 'Aclonica', Color textColor = Colors.black, double fontSize = 15.0, FontWeight fontWeight = FontWeight.normal, TextOverflow overflow = TextOverflow.visible, int maxLines = 100000, TextAlign alignment = TextAlign.start}) {
    return Text(
      content,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: alignment,
      style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
        decoration: TextDecoration.none
      ),
    );
  }

  static appbar(String title, {List<Widget>? actions, bool showBackButton = true, Function()? onBackPressed, SystemUiOverlayStyle? systemUiOverlayStyle, Color color = Colors.black}) {
    return AppBar(
      systemOverlayStyle: systemUiOverlayStyle,
      automaticallyImplyLeading: false,
      forceMaterialTransparency: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8),
        child: IconButton(
          onPressed: () {
            if (onBackPressed != null) {
              onBackPressed();
            } else {
              ajugnuGlobalContext.currentState?.pop();
            }
          }, icon: Visibility(visible:showBackButton,child: Icon(Icons.arrow_back, color: color)),
        ),
      ),
      actions: actions,
      title: Padding(
        padding: EdgeInsets.only(right: actions == null || actions.isEmpty ? 42 : 0),
        child: Center(
          child: text(title, fontSize: 17, textColor: color, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  static void removeProgress() {
    if (isAjugnuGlobalContextMounted() && isProgressBarVisible) {
      Navigator.pop(getAjungnuGlobalContext());
      isProgressBarVisible = false;
    }
  }

  static void showProgress() {
    if (!isAjugnuGlobalContextMounted()) {
      return;
    }
    isProgressBarVisible = true;
    double size = min(MediaQuery.of(getAjungnuGlobalContext()).size.width, MediaQuery.of(getAjungnuGlobalContext()).size.height) * 0.22;
    showDialog(context: getAjungnuGlobalContext(), builder: (context) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.all(Radius.circular(size * 0.18))
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: SizedBox(
                        height: size * 0.5,
                        width: size * 0.5,
                        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.inversePrimary)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }, barrierDismissible: false);
  }




}

class ReadMoreText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ReadMoreText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
  });

  @override
  State<StatefulWidget> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final maxLines = widget.maxLines;
    final style = widget.style ?? DefaultTextStyle.of(context).style;

    TextSpan link = TextSpan(
      text: ' Read more',
      style: style.copyWith(color: Colors.green),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          setState(() {
            _expanded = !_expanded;
          });
        },
    );

    TextSpan span = TextSpan(text: text, style: style);

    TextPainter textPainter = TextPainter(
      text: span,
      maxLines: _expanded ? null : maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);

    if (textPainter.didExceedMaxLines) {
      return RichText(
        text: TextSpan(
          style: style,
          children: [
            TextSpan(
              text: _expanded ? text : '${text.substring(0, textPainter.getPositionForOffset(Offset(textPainter.size.width, textPainter.preferredLineHeight * maxLines)).offset)}...',
              style: style,
            ),
            link,
          ],
        ),
      );
    } else {
      return Text(text, style: style);
    }
  }
}
