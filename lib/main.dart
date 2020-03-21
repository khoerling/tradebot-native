import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class TradeBot extends StatefulWidget {
  @override
  _TradeBotState createState() => _TradeBotState();
}

class _TradeBotState extends State<TradeBot> {
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
        body: Material(
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
                ])
              ],
            ),
          ),
        ));
  }
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(18, 21, 54, 1),
        scaffoldBackgroundColor: Color.fromRGBO(18, 21, 54, 1),
        primaryColor: Color.fromRGBO(18, 21, 54, 1),
        accentColor: Colors.cyan[600],
        textTheme: TextTheme(
          headline5: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: TradeBot(),
    ),
  );
}
