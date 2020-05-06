import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:tradebot_native/components/crypto_icon.dart';
import 'package:tradebot_native/models/user.dart';
import 'package:tradebot_native/models/alert.dart';

class AlertList extends StatefulWidget {
  const AlertList({
    Key key,
  }) : super(key: key);
  @override
  _AlertList createState() => _AlertList();
}

class _AlertList extends State<AlertList> {
  User _user;

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
    print('render');
    if (_user.alerts.isEmpty) return Container(); // guard
    // sort alerts alerted desc, created desc
    _user.alerts.sort((a, b) {
      // sort by alerted first
      if (a.isAlerted && b.isAlerted)
        return b.alerted.last.compareTo(a.alerted.last);
      if (a.isAlerted && !b.isAlerted) return 1;
      if (b.isAlerted && !a.isAlerted) return -1;
      // sort by created
      return b.created.compareTo(a.created);
    });
    return SizedBox.expand(
        child: ListView.separated(
            itemCount: _user.alerts?.length ?? 0,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              final alert = _user.alerts[index],
                  base = alert.market['base'].toLowerCase();
              return Dismissible(
                  key: Key(alert.id),
                  onDismissed: (direction) {
                    HapticFeedback.selectionClick();
                    _user.alerts =
                        _user.alerts.where((a) => a.id != alert.id).toList();
                    _user.save();
                    if (_user.alerts.length < 1)
                      EventEmitter.publish('selectPage', 0);
                  },
                  secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: Colors.white, size: 35),
                      color: Colors.red),
                  background: Container(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.delete, color: Colors.white, size: 35),
                      color: Colors.red),
                  child: ListTile(
                      onTap: () => Navigator.pushNamed(context, '/alert',
                          arguments: alert),
                      isThreeLine: true,
                      leading:
                          Hero(tag: alert.id, child: CryptoIcon(name: base)),
                      title: Text(
                          "${alert.market['quote']} ➤ ${alert.exchange.toUpperCase()}"),
                      subtitle: Text(subtitleFor(alert.name, alert.params) +
                          ', ' +
                          alert.timeframe.toString() +
                          "\n" +
                          (alert.isAlerted
                              ? "Alerted ${alert.alerted[0].millisecondsSinceEpoch}"
                              : "Created ${formatTime(alert.created.millisecondsSinceEpoch)}")),
                      trailing: Icon(Icons.keyboard_arrow_right,
                          color: Colors.white.withOpacity(.1), size: 30.0)));
            }));
  }

  subtitleFor(AlertName name, params) {
    switch (name) {
      case AlertName.guppy:
        try {
          return "Guppy is " + EnumToString.parse(params['guppy']);
        } catch (e) {
          return "Guppy is ${params['guppy']}";
        }
        break;
      case AlertName.divergence:
        return "${params['divergence_bearish'] != null ? 'Bearish' : 'Bullish'} ${params['divergence_hidden'] != null ? 'Hidden ' : ''}Divergence";
      case AlertName.price:
        return "Price ${params['price_horizon'] == 'greater' ? '↑' : '↓'} ${params['price_amount']}";
    }

    return "";
  }
}
