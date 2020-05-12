import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:tradebot_native/models/user.dart';
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
    List alerted = alert.alerted.reversed.toList();
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
                  Positioned(
                      top: 125,
                      left: 50,
                      child: SizedBox(
                          height: 300,
                          width: 500,
                          child: ListView.builder(
                              itemCount: alerted?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                DateTime time = alerted[index];
                                return ListTile(
                                    title: Text(formatTime(
                                        time.millisecondsSinceEpoch)),
                                    subtitle: Text(
                                        DateFormat('MMMM d, yyyy @ HH:mm:ss')
                                            .format(time)));
                              }))),
                ],
              )))
    ]));
  }
}
