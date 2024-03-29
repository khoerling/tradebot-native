import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:provider/provider.dart';
import 'package:tradebot_native/models/user.dart';
import 'package:tradebot_native/models/alert.dart';
import 'package:tradebot_native/components/linked_label_checkbox.dart';
import 'package:tradebot_native/components/crypto_icon.dart';
import 'package:tradebot_native/components/weekly_chart.dart';
import 'package:tradebot_native/pages/pages.dart';
import '../custom_color_scheme.dart';

class AlertDetail extends StatefulWidget {
  const AlertDetail({Key key, this.page, this.alert}) : super(key: key);
  final TPage page;
  final Alert alert;

  @override
  _AlertDetail createState() => _AlertDetail();
}

class _AlertDetail extends State<AlertDetail> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final base = widget.alert.market['base'].toLowerCase();
    final alerted = widget.alert.alerted.reversed.toList();

    return Consumer<User>(builder: (context, user, child) {
      Future<void> confirm(Function cb) async {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).accentColor,
              title: Text("Really Delete?"),
              actions: <Widget>[
                FlatButton(
                  child: Text('YES',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    user.deleteAlert(widget.alert.id);
                    Navigator.of(context).pop();
                    cb();
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      return Scaffold(
          body: CustomScrollView(slivers: [
        SliverAppBar(
            expandedHeight: 125.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Hero(
                  tag: widget.alert.id,
                  child: CryptoIcon(height: 45.0, width: 45.0, name: base)),
            )),
        SliverFixedExtentList(
            itemExtent: 40,
            delegate: SliverChildListDelegate([
              Center(
                  child: Text(
                "${widget.alert.market['quote']} » ${widget.alert.exchange.toUpperCase()}",
                style: tt.headline4,
              )),
              Center(
                  child: Text(
                widget.alert.subtitle(),
                style: tt.headline6,
              )),
              Center(
                  child: SizedBox(
                      width: 120,
                      height: 18,
                      child: LinkedLabelCheckbox(
                          label: "Silenced",
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          value: widget.alert.isSilenced,
                          onChanged: (value) {
                            widget.alert.isSilenced = !widget.alert.isSilenced;
                            user.save();
                            setState(() => {});
                          }))),
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
                    "Created ${formatTime(widget.alert.created.millisecondsSinceEpoch)}",
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
            child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: FlatButton(
            child: Text('DELETE', style: TextStyle(color: cs.danger)),
            onPressed: () {
              confirm(() => Navigator.of(context).pop());
            },
          ),
        )),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(bottom: 75),
          ),
        ),
      ]));
    });
  }
}
