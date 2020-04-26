import 'package:flutter/material.dart';
import 'package:tradebot_native/models/alert.dart';
import 'package:tradebot_native/pages/pages.dart';

class AlertDetail extends StatelessWidget {
  const AlertDetail({Key key, this.page, this.alert}) : super(key: key);
  final TPage page;
  final Alert alert;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        SafeArea(
          child: BackButton(),
        ),
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Stack(
              alignment: FractionalOffset.center,
              overflow: Overflow.visible,
              children: [
                Center(child: Text("TODO Alert ${alert.name} Details Screen")),
              ],
            )),
      ]),
    );
  }
}
