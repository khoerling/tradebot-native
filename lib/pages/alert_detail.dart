import 'package:flutter/material.dart';
import 'package:tradebot_native/models/alert.dart';
import 'package:tradebot_native/components/crypto_icon.dart';
import 'package:tradebot_native/pages/pages.dart';

class AlertDetail extends StatelessWidget {
  const AlertDetail({Key key, this.page, this.alert}) : super(key: key);
  final TPage page;
  final Alert alert;

  @override
  Widget build(BuildContext context) {
    String base = alert.market['base'].toLowerCase();
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
                CryptoIcon(name: alert.market),
                Center(child: Text("TODO Alert ${alert.name} Details Screen")),
              ],
            )),
      ]),
    );
  }
}
