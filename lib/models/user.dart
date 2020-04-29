import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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
  final Firestore _db = Firestore.instance;

  User({
    this.id,
    this.key,
    this.email,
    this.deviceId,
    this.pushToken,
    this.alerts,
    this.created,
    this.updated,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    if (data == null) return User(); // guard
    var alerts = data['alerts'];
    try {
      return User(
          id: data['id'],
          email: data['email'],
          deviceId: data['deviceId'],
          pushToken: data['pushToken'],
          alerts: alerts != null
              ? alerts
                  .map((alert) => Alert.fromMap(alert))
                  .toList()
                  .cast<Alert>()
              : [],
          created: timeFor('created', data),
          updated: timeFor('updated', data));
    } catch (e) {
      print("Error User.fromMap $e");
    }
    return User();
  }

  static Future<User> fromFirestore(id) async {
    Firestore db = Firestore.instance;
    DocumentSnapshot doc = await db.collection('users').document(id).get();
    return User.fromMap(doc.data);
  }

  static Future<User> restore() async {
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString(storageKey);
    print('RESTORED $user');
    return user == null ? User.fromFirestore(storageKey) : User.fromMap(json.decode(user));
  }

  static DateTime timeFor(String key, Map data) {
    var epoch = DateTime.fromMicrosecondsSinceEpoch(0);
    try {
      return DateTime.parse(data[key]) ?? epoch;
    } catch (e) {
      return epoch;
    }
  }

  toJson() {
    return {
      'id': id,
      'email': email,
      'deviceId': deviceId,
      'pushToken': pushToken,
      'alerts': alerts != null ? alerts.map((a) => a.toJson()).toList() : [],
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
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
    var future = _db.collection('users').document(id).setData(toJson());
    try {
      created = updated = DateTime.now();
      future
          .then((_) => save())
          .catchError((e) => print("Error creating User: $e"));
    } catch (e) {
      print("Exception creating User: $e");
    }
    return future;
  }

  Future<void> createAlert(Alert alert) {
    print('+ alert');
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
    final prefs = await SharedPreferences.getInstance();
    // sort alerts alerted desc, created desc
    alerts.sort((a, b) {
      // TODO alerted sort to top
      if (a.created.microsecondsSinceEpoch < b.created.microsecondsSinceEpoch)
        return 1;
      if (a.created.microsecondsSinceEpoch > b.created.microsecondsSinceEpoch)
        return -1;
      return 0;
    });
    prefs.setString(storageKey, toString());
    notifyListeners();
  }
}
