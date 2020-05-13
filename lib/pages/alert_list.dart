import 'dart:async';
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
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      if (user.alerts.isEmpty) return Container(); // guard
      // sort alerts alerted desc, created desc
      user.alerts.sort((a, b) {
        if (a?.alerted == null) return 1; // guard
        if (a.alerted.isNotEmpty && b.alerted.isNotEmpty)
          return b.alerted.last.compareTo(a.alerted.last);
        if (a.alerted.isEmpty && b.alerted.isNotEmpty) return 1;
        if (b.alerted.isEmpty && a.alerted.isNotEmpty) return -1;
        return b.created.compareTo(a.created);
      });
      return SizedBox.expand(
          child: ListView.separated(
              itemCount: user.alerts?.length ?? 0,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(user, user.alerts[index], index);
              }));
    });
  }

  Widget _buildItem(User user, Alert alert, int index) {
    final base = alert.market['base'].toLowerCase();
    return Dismissible(
        key: Key(alert.id),
        onDismissed: (direction) {
          HapticFeedback.selectionClick();
          user.alerts = user.alerts.where((a) => a.id != alert.id).toList();
          user.save();
          if (user.alerts.length < 1) EventEmitter.publish('selectPage', 0);
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
            onTap: () {
              Navigator.pushNamed(context, '/alert', arguments: alert);
              Timer(Duration(milliseconds: 25), () {
                user.resetAlert(alert);
                setState(() {}); // refresh ui
              });
            },
            isThreeLine: true,
            leading: Hero(tag: alert.id, child: CryptoIcon(name: base)),
            title: Text(
                "${alert.market['quote']} ➤ ${alert.exchange.toUpperCase()}",
                style: TextStyle(
                    fontWeight:
                        alert.isAlerted ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(
              subtitleFor(alert.name, alert.params) +
                  ', ' +
                  alert.timeframe.toString() +
                  "\n" +
                  (alert?.alerted?.isNotEmpty ?? false
                      ? "Last Alerted ${formatTime(alert.alerted.last.millisecondsSinceEpoch)}"
                      : "Created ${formatTime(alert.created.millisecondsSinceEpoch)}"),
              style: TextStyle(
                  color: alert.isAlerted
                      ? Colors.white
                      : Colors.white.withOpacity(.5)),
            ),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.white.withOpacity(alert.isAlerted ? 1 : .1),
                size: 30.0)));
  }

  subtitleFor(AlertName name, params) {
    switch (name) {
      case AlertName.guppy:
        try {
          return "Guppy is " +
              EnumToString.parse(params['guppy']).toUpperCase();
        } catch (e) {
          return "Guppy is ${params['guppy'].toUpperCase()}";
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
