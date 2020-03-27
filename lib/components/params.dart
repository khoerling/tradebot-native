import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class Params extends StatefulWidget {
  final Widget child;
  Params({Key key, this.child}) : super(key: key);

  @override
  _ParamsState createState() => _ParamsState();
}

class _ParamsState extends State<Params> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tab = (String name) => Padding(
        padding: EdgeInsets.only(top: 15, bottom: 15),
        child: Text(name.toUpperCase(), style: TextStyle(fontSize: 12)));
    return Padding(
        padding: EdgeInsets.only(top: 35.0),
        child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white30,
            tabs: [
              tab('Price'),
              tab('Divergence'),
              tab('Guppy'),
            ]));
  }
}
