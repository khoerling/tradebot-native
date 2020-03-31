import 'package:flutter/material.dart';
import 'package:tradebot_native/pages/pages.dart';

// TODO Replace with object model.

class AlertDetail extends StatelessWidget {
  const AlertDetail({Key key, this.page}) : super(key: key);
  final TPage page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(child: Center(child: Text("Alert Details Screen"))),
    );
  }
}
