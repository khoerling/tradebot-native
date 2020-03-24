import 'package:flutter/material.dart';
import 'package:tradebot_native/pages/pages.dart';

// TODO Replace with object model.
class ListAlerts extends StatelessWidget {
  const ListAlerts({Key key, this.page}) : super(key: key);

  final Page page;

  @override
  Widget build(BuildContext context) {
    const List<int> shades = <int>[
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ];

    return 
      SizedBox.expand(
        child: ListView.builder(
          itemCount: shades.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 128,
              child: Card(
                color: Colors.white.withOpacity(0.075),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/alert");
                  },
                  child: Center(
                    child: Text('Alert $index'),
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}
