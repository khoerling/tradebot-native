import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_id/device_id.dart';
import 'package:uuid/uuid.dart';
import 'package:tradebot_native/push_notifications.dart';
import 'package:tradebot_native/models/alert.dart';

const storageKey = 'tradebot:user6';

class User with ChangeNotifier {
  String id;
  String key;
  String email;
  String deviceId;
  String pushToken;
  List<Alert> alerts;
  DateTime created;
  DateTime updated;
  int seenIntro;
  final Firestore _db = Firestore.instance;

  User({
    this.id,
    this.key,
    this.email,
    this.deviceId,
    this.pushToken,
    this.alerts = const [],
    this.created,
    this.updated,
    this.seenIntro = 0,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    final alerts = data['alerts'];
    try {
      return User(
          id: data['id'],
          email: data['email'],
          deviceId: data['deviceId'],
          pushToken: data['pushToken'],
          seenIntro: data['seenIntro'],
          alerts: alerts
                  ?.map((alert) => Alert.fromMap(alert))
                  ?.toList()
                  ?.cast<Alert>() ??
              [],
          created: timeFor('created', data),
          updated: timeFor('updated', data));
    } catch (e) {
      print("Error User.fromMap $e");
    }
    return User();
  }

  static Future<User> fromLocalStorage() async {
    return DeviceId.getID.then((id) async {
      User user;
      try {
        final prefs = await SharedPreferences.getInstance(),
            restored = prefs.getString(storageKey);
        if (restored == null) {
          // create user
          user = User(id: id, deviceId: id);
          print('+ User');
        } else {
          // restore user
          user = User.fromMap(json.decode(restored));
          print('Restored User');
        }
        user.id = id;
        user.deviceId = id;
        return user;
      } catch (err) {
        print('User.fromLocalStorage: $err');
      }
      return user;
    });
  }

  static DateTime timeFor(String key, Map data) {
    final epoch = DateTime.fromMicrosecondsSinceEpoch(0);
    try {
      return DateTime.parse(data[key]) ?? epoch;
    } catch (e) {
      return epoch;
    }
  }

  Future<String> get requestPushToken async {
    final PushNotifications _pushNotifications = PushNotifications();
    return _pushNotifications.getToken().then((token) {
      pushToken = token;
      save();
      return token;
    });
  }

  List<Alert> get activeAlerts {
    alerts.sort(_sorter);
    return alerts;
  }

  int _sorter(Alert a, Alert b) {
    // isAlerted to top
    if (a.isAlerted && !b.isAlerted) return -1;
    if (!a.isAlerted && b.isAlerted) return 1;
    // has EVER alerted, if both-- alerted DESC
    if (a.alerted.isEmpty && b.alerted.isNotEmpty) return 1;
    if (a.alerted.isNotEmpty && b.alerted.isEmpty) return -1;
    if (a.alerted.isNotEmpty && b.alerted.isNotEmpty)
      return b.alerted.last.compareTo(a.alerted.last);
    // last updated DESC
    int r = b.updated.compareTo(a.updated);
    if (r != 0) return r;
    // created by DESC
    return b.created.compareTo(a.created);
  }

  stream() async {
    try {
      // then, stream
      _db.collection('users').document(id).snapshots().listen((doc) {
        final user = User.fromMap(doc.data);
        // freshen these values:
        alerts = user.alerts;
        email = user.email;
        created = user.created;
        updated = user.updated;
        // ...and, save locally + broadcast
        save();
        notifyListeners();
      });
    } catch (e) {
      print("User.restore: $e");
    }
  }

  toJson() {
    try {
      return {
        'id': id,
        'email': email,
        'deviceId': deviceId,
        'pushToken': pushToken,
        'seenIntro': seenIntro,
        'alerts': alerts?.map((a) => a.toJson())?.toList() ?? [],
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
      };
    } catch (e) {
      print("User.toJson: $e");
    }
    return {};
  }

  toString() {
    return json.encode(this);
  }

  Future<void> create() {
    final future = _db.collection('users').document(id).setData(toJson());
    try {
      created = updated = DateTime.now();
      future
          .then((_) => save())
          .catchError((e) => print("Error creating User: $e"));
    } catch (e) {
      print("User.create: $e");
    }
    return future;
  }

  Future<void> createAlert(Alert alert) {
    print('+ Alert');
    if (alert == null) return Future.value(false); // guard
    alert.id = Uuid().v4();
    alert.created = alert.updated = DateTime.now();
    if (alerts != null)
      alerts += [alert];
    else
      alerts = [alert];
    final future = _db.collection('users').document(id).setData(toJson());
    future.then((_) => save());
    return future;
  }

  save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final future =
          _db.collection('users').document(id).setData(toJson()); // don't wait
      prefs.setString(storageKey, toString());
      notifyListeners();
      print('USER' + toString());
      return future;
    } catch (e) {
      print("User.save: $e");
    }
  }
}
