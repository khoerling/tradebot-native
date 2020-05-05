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
            child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Positioned(
                      top: 25,
                      child: BackButton(),
                    ),
                    Positioned(
                      top: 0,
                      left: 50,
                      child: Hero(
                          tag: alert.id,
                          child: CryptoIcon(
                              height: 100.0, width: 100.0, name: base)),
                    ),
                    Center(
                        child: Text("TODO Alert ${alert.name} Details Screen")),
                  ],
                ))),
      ]),
    );
  }
}
