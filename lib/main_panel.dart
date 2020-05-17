import 'package:flutter/material.dart';

class ShapeDisplayWidget extends StatelessWidget {
  final AssetImage image;
  final List<Widget> widgets;

  ShapeDisplayWidget(this.image, this.widgets);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      image != null
          ? Image(
              image: image,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
            )
          : Container(),
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: widgets,
        ),
      ),
    ]);
  }
}
