import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';

// TODO 1st, refactor push out
// TODO 2nd, delete this file

class Layout extends StatefulWidget {
  final Widget child;

  const Layout({Key key, this.child}) : super(key: key);

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  String _pushToken = "Waiting for token...";
  String _messageText = "Waiting for message...";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _pushToken = "Push Messaging token: $token";
      });
      print(_pushToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('TradeBot'),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
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
            // switch to new top-level section
            setState(() {
              _page = index;
            });
          },
        ),
        body: Material(
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                Center(
                  child: SelectableText(_pushToken),
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(_messageText)),
                  ),
                ]),
                Center(child: widget.child)
              ],
            ),
          ),
        ));
  }
}
