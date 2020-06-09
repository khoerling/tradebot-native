import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_formatter/time_formatter.dart';
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
    TextTheme tt = Theme.of(context).textTheme;
    String base = alert.market['base'].toLowerCase();
    List alerted = alert.alerted.reversed.toList();
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
          expandedHeight: 125.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Hero(
                tag: alert.id,
                child: CryptoIcon(height: 45.0, width: 45.0, name: base)),
          )),
      SliverFixedExtentList(
          itemExtent: 40,
          delegate: SliverChildListDelegate([
            Center(
                child: Text(
              "${alert.market['quote']} » ${alert.exchange.toUpperCase()}",
              style: tt.headline4,
            )),
            Center(
                child: Text(
              alert.subtitle(),
              style: tt.headline6,
            )),
          ])),
      SliverToBoxAdapter(child: WeeklyChart(alerted: alerted)),
      SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.only(top: 75, bottom: 5),
              child: Center(
                  child: Text(
                      "${alerted.length == 0 ? 'No' : alerted.length} ALERT${alerted.length < 2 ? '' : 'S'}",
                      style: tt.headline5)))),
      SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Center(
                child: Text(
                  "Created ${formatTime(alert.created.millisecondsSinceEpoch)}",
                  style: tt.headline6,
                ),
              ))),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            DateTime time = alerted[index];
            return ListTile(
                subtitle: Text(formatTime(time.millisecondsSinceEpoch)),
                title:
                    Text(DateFormat('MMMM d, yyyy @ HH:mm:ss').format(time)));
          },
          childCount: alerted?.length ?? 0,
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.only(bottom: 75),
        ),
      ),
    ]));
  }
}
