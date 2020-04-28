import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        Icon(Icons.add, color: Colors.white, size: 33),
        Icon(Icons.list, color: Colors.white, size: 33),
        // Icon(Icons.perm_identity, color: Colors.black, size: 33),
      ],
      color: Colors.white.withOpacity(.06),
      buttonBackgroundColor: Colors.white.withOpacity(.06),
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeOutExpo,
      animationDuration: Duration(milliseconds: 500),
      onTap: (index) {
        if (_page == index) return; // guard
        HapticFeedback.selectionClick();
        Future.delayed(
            Duration(milliseconds: 351), () => HapticFeedback.mediumImpact());
        setState(() {
          _page = index;
        });
        widget.onTap(_page);
      },
    );
  }
}
