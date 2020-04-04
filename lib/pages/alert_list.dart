import 'package:flutter/material.dart';

class AlertList extends StatefulWidget {
  const AlertList({
    Key key,
  }) : super(key: key);
  @override
  _AlertList createState() => _AlertList();
}

// class _CreateAlert extends State<AlertCreate> {
class _AlertList extends State<AlertList> {
  List<int> shades = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ListView.builder(
        itemCount: shades.length,
        itemBuilder: (BuildContext context, int index) {
          final item = shades[index];
          return Dismissible(
              key: Key(item.toString()),
              onDismissed: (direction) {
                setState(() {
                  shades.removeAt(index);
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
                      child: Text('Alert ${item}'),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
