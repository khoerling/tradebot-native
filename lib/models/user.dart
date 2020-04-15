import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradebot_native/models/alert.dart';

const storageKey = 'tradebot:user';

class User {
  String id;
  String key;
  String email;
  String deviceId;
  String pushToken;
  List<Alert> alerts;
  DateTime created;
  DateTime updated;

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

  User.fromDocument(DocumentSnapshot doc)
      : id = doc.documentID,
        email = doc.data['email'],
        deviceId = doc.data['deviceId'],
        pushToken = doc.data['pushToken'],
        alerts = doc.data['alerts'] ?? [],
        created = timeFor('created', doc.data),
        updated = timeFor('updated', doc.data);

  static DateTime timeFor(String key, Map data) {
    return data.containsKey(key) && data[key] != null
        ? DateTime.parse(data[key])
        : DateTime.fromMicrosecondsSinceEpoch(0);
  }

  toJson() {
    return {
      'id': id,
      'email': email,
      'deviceId': deviceId,
      'pushToken': pushToken,
      'alerts': alerts.map((a) => a.toJson()),
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  toString() {
    return json.encode(toJson());
  }

  save() async {
    // TODO firestore
    final prefs = await SharedPreferences.getInstance();
    json.decode(prefs.getString(storageKey));
  }

  restore() async {
    // TODO firestore
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(storageKey, toString());
  }
}