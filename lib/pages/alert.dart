import 'package:flutter/material.dart';
import 'package:tradebot_native/pages/pages.dart';

// TODO Replace with object model.

class Alert extends StatelessWidget {
  const Alert({Key key, this.page}) : super(key: key);
  final Page page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(child: Center(child: Text("Alert Details Screen"))),
    );
  }
}
