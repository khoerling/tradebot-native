import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavigation extends StatefulWidget {
  final onTap;
  final index;

  const BottomNavigation({Key key, this.index, this.onTap}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      _page = widget.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      key: _bottomNavigationKey,
      index: _page,
      height: 75.0,
      items: <Widget>[
        Icon(Icons.add, color: Colors.black, size: 33),
        Icon(Icons.list, color: Colors.black, size: 33),
        Icon(Icons.perm_identity, color: Colors.black, size: 33),
      ],
      color: Colors.white,
      buttonBackgroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeOutExpo,
      animationDuration: Duration(milliseconds: 500),
      onTap: (index) {
        setState(() {
          _page = index;
        });
        widget.onTap(_page);
      },
    );
  }
}
