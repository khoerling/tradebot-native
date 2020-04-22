import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return SizedBox.expand(
        child: ListView.builder(
            itemCount: _user.alerts.length,
            itemBuilder: (BuildContext context, int index) {
              final alert = _user.alerts[index];
              return Dismissible(
                  key: Key(alert.id),
                  onDismissed: (direction) {
                    HapticFeedback.selectionClick();
                    _user.alerts =
                        _user.alerts.where((a) => a.id != alert.id).toList();
                    _user.save();
                  },
                  secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: Colors.white, size: 35),
                      color: Colors.red),
                  background: Container(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.delete, color: Colors.white, size: 35),
                      color: Colors.red),
                  child: SizedBox(
                    height: 128,
                    child: Card(
                      color: Colors.white.withOpacity(0.075),
                      child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/alert');
                          },
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text("${Alert.nameFor(alert.name)}"),
                                ),
                                Center(
                                  child:
                                      Text("${(alert.exchange.toUpperCase())}"),
                                ),
                                Center(
                                  child: Text("${(alert.market)}"),
                                ),
                                Center(
                                  child: Text(
                                      "created: ${alert.created.toString()}"),
                                ),
                                Center(
                                  child: Text("last alerted: never"),
                                ),
                              ])),
                    ),
                  ));
            }));
  }
}
