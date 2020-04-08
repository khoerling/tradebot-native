import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradebot_native/models/alert.dart';

class AlertList extends StatefulWidget {
  const AlertList({
    Key key,
  }) : super(key: key);
  @override
  _AlertList createState() => _AlertList();
}

class _AlertList extends State<AlertList> {
  final db = Firestore.instance;
  final ref = Firestore.instance.collection('alerts');
  List<Alert> alerts = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: StreamBuilder<QuerySnapshot>(
      stream: ref.orderBy('created', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading Your Alerts');
          default:
            return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final alert =
                      Alert.fromDocument(snapshot.data.documents[index]);
                  return Dismissible(
                      key: Key(alert.id),
                      onDismissed: (direction) {
                        ref.document(alert.id).delete();
                      },
                      secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            iconSize: 50,
                            icon: Icon(Icons.delete),
                          ),
                          color: Colors.red),
                      background: Container(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            iconSize: 50,
                            icon: Icon(Icons.delete),
                          ),
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
                                      child:
                                          Text("${Alert.nameFor(alert.name)}"),
                                    ),
                                    Center(
                                      child: Text(
                                          "${(alert.exchange.toUpperCase())}"),
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
                });
        }
      },
    ));
  }
}
