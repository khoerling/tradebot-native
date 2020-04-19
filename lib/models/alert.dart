import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertGuppy { green, red, grey }
enum AlertName { price, divergence, guppy }
enum AlertPrice { greater, less }

// used to enum -> string <- enum
const enums = [AlertGuppy, AlertName, AlertPrice];

class Alert {
  String id;
  String key;
  AlertName name;
  String exchange;
  String market;
  String timeframe;
  List<DateTime> alerted;
  DateTime created;
  DateTime updated;
  Map<String, dynamic> params = {};

  Alert(
      {this.id,
      this.key,
      this.name,
      this.exchange,
      this.market,
      this.timeframe,
      this.alerted,
      this.created,
      this.updated,
      this.params});

  factory Alert.fromMap(Map data) {
    return Alert(
        id: data['id'],
        name: data['name'],
        exchange: data['exchange'],
        market: data['market'],
        timeframe: data['timeframe'],
        alerted: data['alerted'] ?? [],
        created: timeFor('created', data),
        updated: timeFor('updated', data));
  }

  Alert.fromDocument(DocumentSnapshot doc)
      : id = doc.documentID,
        name = EnumToString.fromString(AlertName.values, doc.data['name']),
        exchange = doc.data['exchange'],
        market = doc.data['market'],
        timeframe = doc.data['timeframe'],
        alerted = doc.data['alerted'] ?? [],
        created = timeFor('created', doc.data),
        updated = timeFor('updated', doc.data),
        params = doc.data['params'] ?? {};

  static DateTime timeFor(String key, Map data) {
    return data.containsKey(key) && data[key] != null
        ? DateTime.parse(data[key])
        : DateTime.fromMicrosecondsSinceEpoch(0);
  }

  static String nameFor(AlertName alertName) {
    switch (alertName) {
      case AlertName.guppy:
        return "Guppy";
      case AlertName.divergence:
        return "Divergence";
      case AlertName.price:
        return "Price";
    }
    return "Price";
  }

  toJson() {
    var ps = params.map((k, v) =>
        MapEntry(k, enums.contains(v.runtimeType) ? EnumToString.parse(v) : v));
    return {
      'id': id,
      'exchange': exchange,
      'market': market,
      'timeframe': timeframe,
      'alerted': alerted,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'name': EnumToString.parse(name),
      'params': ps,
    };
  }
}
