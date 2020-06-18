import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:tradebot_native/components/crypto_icon.dart';
import 'package:tradebot_native/models/alert.dart';
import 'package:tradebot_native/models/user.dart';

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
      return SizedBox.expand(
          child: ListView.separated(
              itemCount: user.activeAlerts?.length ?? 0,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(user, user.activeAlerts[index], index);
              }));
    });
  }

  Widget _buildItem(User user, Alert alert, int index) {
    final base = alert.market['base'].toLowerCase();
    final len = alert.alerted.length;
    return Dismissible(
        key: Key(alert.id),
        direction: alert.isAlerted
            ? DismissDirection.horizontal
            : DismissDirection.endToStart,
        confirmDismiss: (direction) {
          if (direction == DismissDirection.startToEnd) {
            // reset alert
            if (alert.isAlerted) {
              HapticFeedback.selectionClick();
              alert.resetAlert();
              setState(() {}); // refresh ui
              user.save();
            }
            return Future.value(false);
          }
          return Future.value(true);
        },
        onDismissed: (direction) async {
          HapticFeedback.lightImpact();
          await user.deleteAlert(alert.id);
          if (user.activeAlerts.length < 1)
            EventEmitter.publish('selectPage', 0);
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
                alert.resetAlert();
                setState(() {}); // refresh ui
              });
            },
            enabled: hasAlerted(alert),
            isThreeLine: true,
            leading: Hero(
                tag: alert.id,
                child: CryptoIcon(color: Colors.white, name: base)),
            title: Text(
                "${alert.market['quote']} » ${alert.exchange.toUpperCase()}",
                style: TextStyle(
                    fontWeight:
                        alert.isAlerted ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(
              alert.subtitle() +
                  ', ' +
                  alert.timeframe.toString() +
                  "\n" +
                  (hasAlerted(alert)
                      ? "Alerted ${len < 2 ? 'once' : len.toString() + '⨉'}, ${formatTime(alert.alerted.last.millisecondsSinceEpoch)}"
                      : "Created ${formatTime(alert.created.millisecondsSinceEpoch)}"),
              style: hasAlerted(alert)
                  ? TextStyle(
                      color:
                          Colors.white.withOpacity(alert.isAlerted ? 1 : .75))
                  : null,
            ),
            trailing: hasAlerted(alert)
                ? Icon(Icons.keyboard_arrow_right,
                    color: alert.isAlerted
                        ? Theme.of(context).accentColor
                        : Colors.white.withOpacity(.2),
                    size: 30.0)
                : null));
  }

  hasAlerted(alert) {
    return alert?.alerted?.isNotEmpty ?? false;
  }
}
