import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';

class PushNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _pushToken;

  PushNotifications() {
    print('+ push notice');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
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
      _pushToken = token;
      EventEmitter.publish('pushToken', token);
      print(_pushToken);
    });
  }
}
