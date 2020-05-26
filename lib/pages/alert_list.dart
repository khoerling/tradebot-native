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
      if (user.activeAlerts.isEmpty) return Container(); // guard
      // sort alerts alerted desc, created desc
      user.activeAlerts.sort(_sorter);
      return SizedBox.expand(
          child: ListView.separated(
              itemCount: user.activeAlerts?.length ?? 0,
              separatorBuilder: (context, index) => Container(),
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(user, user.activeAlerts[index], index);
              }));
    });
  }

  Widget _buildItem(User user, Alert alert, int index) {
    final base = alert.market['base'].toLowerCase();
    return Dismissible(
        key: Key(alert.id),
        confirmDismiss: (direction) {
          if (direction == DismissDirection.startToEnd) {
            // reset alert
            HapticFeedback.selectionClick();
            user.activeAlerts.firstWhere((a) => a.id == alert.id).resetAlert();
            setState(() {}); // refresh ui
            return Future.value(false);
          }
          return Future.value(true);
        },
        onDismissed: (direction) {
          HapticFeedback.selectionClick();
          user.alerts = user.alerts.where((a) => a.id != alert.id).toList();
          user.save();
          if (user.activeAlerts.length < 1) EventEmitter.publish('selectPage', 0);
        },
        secondaryBackground: Container(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: Colors.white, size: 35),
            color: Colors.red),
        background: Container(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.check, color: Colors.white, size: 35),
            color: Colors.blue),
        child: ListTile(
            onTap: () {
              if (!hasAlerted(alert)) return; // guard
              Navigator.pushNamed(context, '/alert', arguments: alert);
              Timer(Duration(milliseconds: 25), () {
                user.resetAlert(alert);
                setState(() {}); // refresh ui
              });
            },
            enabled: hasAlerted(alert),
            isThreeLine: true,
            leading: Hero(tag: alert.id, child: CryptoIcon(name: base)),
            title: Text(
                "${alert.market['quote']} → ${alert.exchange.toUpperCase()}",
                style: TextStyle(
                    fontWeight:
                        alert.isAlerted ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(
              subtitleFor(alert.name, alert.params) +
                  ', ' +
                  alert.timeframe.toString() +
                  "\n" +
                  (hasAlerted(alert)
                      ? "Alerted ${formatTime(alert.alerted.last.millisecondsSinceEpoch)}"
                      : "Created ${formatTime(alert.created.millisecondsSinceEpoch)}"),
              style: hasAlerted(alert)
                  ? TextStyle(
                      color:
                          Colors.white.withOpacity(alert.isAlerted ? 1 : .75))
                  : null,
            ),
            trailing: hasAlerted(alert)
                ? Icon(Icons.keyboard_arrow_right,
                    color: Colors.white.withOpacity(alert.isAlerted ? 1 : .1),
                    size: 30.0)
                : null));
  }

  int _sorter(Alert a, Alert b) {
    if (a?.alerted == null || b?.alerted == null) return 1; // guard
    if (a.alerted.isNotEmpty && b.alerted.isNotEmpty)
      return b.alerted.last.compareTo(a.alerted.last);
    if (a.alerted.isEmpty && b.alerted.isNotEmpty) return 1;
    if (b.alerted.isEmpty && a.alerted.isNotEmpty) return -1;
    return b.created.compareTo(a.created);
  }

  hasAlerted(alert) {
    return alert?.alerted?.isNotEmpty ?? false;
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
