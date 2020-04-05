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

// class _CreateAlert extends State<AlertCreate> {
class _AlertList extends State<AlertList> {
  final db = Firestore.instance;
  List<Alert> alerts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAlerts());
  }

  _fetchAlerts() async {
    // push alert to firebase
    CollectionReference ref = await db.collection("alerts");
    ref.getDocuments().then((QuerySnapshot snapshot) {
      var _alerts = snapshot.documents
          .where((alert) => alert.data['name'] != null)
          .map((alert) => Alert.fromJson(alert.data));
      print('Loaded: ' + _alerts.length.toString());
      alerts.addAll(_alerts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (BuildContext context, int index) {
          final item = alerts[index];
          return Dismissible(
              key: Key(item.toString()),
              onDismissed: (direction) {
                setState(() {
                  alerts.removeAt(index);
                });
              },
              background: Container(color: Colors.red),
              child: SizedBox(
                height: 128,
                child: Card(
                  color: Colors.white.withOpacity(0.075),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, "/alert");
                    },
                    child: Center(
                      child: Text('Alert ${item.name}'),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
