import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:tradebot_native/models/user.dart';
import 'package:tradebot_native/models/alert.dart';
import 'package:tradebot_native/components/crypto_icon.dart';
import 'package:tradebot_native/components/weekly_chart.dart';
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
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Row(children: [
                        Positioned(
                            top: 34,
                            left: 50,
                            child: Text(
                              "${alert.market['quote']} ➤ ${alert.exchange.toUpperCase()}",
                              style: TextStyle(fontSize: 24),
                            )),
                        Hero(
                            tag: alert.id,
                            child: CryptoIcon(
                                height: 50.0, width: 50.0, name: base)),
                      ])),
                ),
              ];
            },
            body: Column(children: [
              WeeklyChart(alerted: alerted),
              alerted?.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: alerted?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        DateTime time = alerted[index];
                        return ListTile(
                            title:
                                Text(formatTime(time.millisecondsSinceEpoch)),
                            subtitle: Text(DateFormat('MMMM d, yyyy @ HH:mm:ss')
                                .format(time)));
                      })
                  : Text('Never alerted.')
            ])));
  }
}
