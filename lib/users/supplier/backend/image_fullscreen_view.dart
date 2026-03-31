import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ajugnu_constants.dart';

class FullScreenImage extends StatelessWidget {
  final List<String> imageUrls;
  final String tag;

   late PageController pageController;

  FullScreenImage({super.key, required this.imageUrls, required int imageIndex, required this.tag}) {
    pageController = PageController(initialPage: imageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
      body: Stack(children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: PageView(
            controller: pageController,
            children: imageUrls.map((img) => Center(
              child: Hero(
                tag: tag,
                child: CachedNetworkImage(
                  imageUrl: img,
                  placeholderFadeInDuration: Duration.zero,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, error) => Container(color: Colors.black12),
                  errorWidget: (context, url, error) => const Image(image: AssetImage("assets/images/gradient_background.png"), fit: BoxFit.cover),
                ),
              ),
            )).toList(),
          ),
        ),
        Positioned(
            top: 50,
            left: 20,
            child: InkWell(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.arrow_back_outlined,
                color: Colors.black,
              ),
            ))
      ]),
    );
  }
}
