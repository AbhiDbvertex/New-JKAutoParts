import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Viewimages extends StatefulWidget {
  final ImageList;
  const Viewimages({Key? key, this.ImageList}) : super(key: key);

  @override
  State<Viewimages> createState() => _ViewimagesState();
}

class _ViewimagesState extends State<Viewimages> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("View Images"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.network(widget.ImageList,errorBuilder: (context, error, stackTrace) {
              return Center(child: Icon(Icons.image_not_supported_outlined,size: 100,));
            },),
          ),
        ],
      ),
    );
  }
}
