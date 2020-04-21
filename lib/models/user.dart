import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradebot_native/models/alert.dart';

const storageKey = 'tradebot:user5';

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

  factory User.fromMap(Map data) {
    var alerts = data['alerts'];
    return User(
        email: data['email'],
        deviceId: data['deviceId'],
        pushToken: data['pushToken'],
        alerts: alerts != null ?
            alerts.map((alert) => Alert.fromMap(alert))
            .toList()
            .cast<Alert>() : [],
        created: timeFor('created', data),
        updated: timeFor('updated', data));
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    User user = User.fromMap(doc.data);
    user.id = doc.documentID;
    return user;
  }

  static Future<User> restore() async {
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString(storageKey);
    return user == null ? User() : User.fromJson(json.decode(user));
  }

  static DateTime timeFor(String key, Map data) {
    return data.containsKey(key) && data[key] != null
        ? DateTime.parse(data[key])
        : DateTime.fromMicrosecondsSinceEpoch(0);
  }

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'];

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
    try {
      created = updated = DateTime.now();
      var future = _db.collection('users').document(id).setData(toJson());
      future
          .then((_) => save())
          .catchError((e) => print("Error creating User: $e"));
      return future;
    } catch (e) {
      print("Exception creating User: $e");
    }
  }

  Future<void> createAlert(Alert alert) {
    alert.created = alert.updated = DateTime.now();
    if (alerts != null)
      alerts += [alert];
    else
      alerts = [alert];
    print(toJson());
    var future = _db.collection('users').document(id).setData(toJson());
    future.then((_) => save());
    return future;
  }

  save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(storageKey, toString());
  }
}
