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
    var alerts = data['alerts'];
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
    // return quickly with local storage
    final PushNotifications _pushNotifications = PushNotifications();
    final _deviceId = () async {
      return await DeviceId.getID;
    };
    return Future.wait([_pushNotifications.getToken(), _deviceId()])
        .then((List res) async {
      User user;
      try {
        final id = res[1],
            prefs = await SharedPreferences.getInstance(),
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
        user.pushToken = res[0];
        user.deviceId = id;
        return user;
      } catch (err) {
        print('User.fromLocalStorage: $err');
      }
      return user;
    });
  }

  static DateTime timeFor(String key, Map data) {
    var epoch = DateTime.fromMicrosecondsSinceEpoch(0);
    try {
      return DateTime.parse(data[key]) ?? epoch;
    } catch (e) {
      return epoch;
    }
  }

  List<Alert> get activeAlerts {
    alerts.sort(_sorter);
    return alerts;
  }

  int _sorter(Alert a, Alert b) {
    // isAlerted to top
    if (a.isAlerted && !b.isAlerted) return -1;
    if (!a.isAlerted && b.isAlerted) return 1;
    // last alerted
    int r = b.updated.compareTo(a.updated);
    if (r != 0) return r;
    // created by
    return b.created.compareTo(a.created);
  }

  resetAlert(Alert alert) async {
    alert
      ..isAlerted = false
      ..updated = DateTime.now();
    notifyListeners();
  }

  restore(cb) async {
    DocumentSnapshot doc = await _db.collection('users').document(id).get();
    // restore these values from snapshot
    alerts = doc['alerts']
            ?.map((alert) => Alert.fromMap(alert))
            ?.toList()
            ?.cast<Alert>() ??
        [];
    email = doc.data['email'];
    created = timeFor('created', doc.data);
    updated = timeFor('updated', doc.data);
    notifyListeners();
    cb(this);
    save();
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

  Stream<User> stream(String id) {
    return _db
        .collection('users')
        .document(id)
        .snapshots()
        .map((snap) => User.fromMap(snap.data));
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
    var future = _db.collection('users').document(id).setData(toJson());
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
