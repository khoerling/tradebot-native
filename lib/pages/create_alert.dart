import 'package:flutter/material.dart';
import 'package:tradebot_native/pages/pages.dart';

// TODO Replace with object model.

class CreateAlert extends StatelessWidget {
  const CreateAlert({Key key, this.page}) : super(key: key);
  final Page page;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox.expand(child: Center(child: Text("Create Alert Screen"))),
    );
  }
}
