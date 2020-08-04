import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';

class PushNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  PushNotifications() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        try {
          var msg = message["aps"]["alert"];
          if (msg != null) {
            // emit push notification received
            HapticFeedback.lightImpact();
            EventEmitter.publish("showInfo", {
              "title": msg["title"].toString(),
              "body": msg["body"].toString()
            });
          }
        } catch (e) {
          // error
          print("Error onMessage: $e");
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        doSelection(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        doSelection(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  void doSelection(message) {
    var data = message['data'];
    if (data['alert_id'] != null)
      // select alert screen
      EventEmitter.publish('selectAlert', data['alert_id']);
    else
      // select detail screen
      EventEmitter.publish('selectPage', 1);
  }

  Future<dynamic> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
