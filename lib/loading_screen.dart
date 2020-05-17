import 'package:flutter/material.dart';

import 'animation/shader_utilities.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,()
    {
      init(() {
        Navigator.pop(context);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F2F2),
      child: Center(
        child: Image(
          image: AssetImage('assets/background/app_icon.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future init(Function onFinished) async {
    await ShaderUtilities.init(context);
    onFinished();
  }
}
