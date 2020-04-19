import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';

class PushNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  PushNotifications() {
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
  }

  Future<dynamic> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
