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
  Map<String, dynamic> params = {};

  Alert(
      {this.id,
      this.key,
      this.name,
      this.exchange,
      this.market,
      this.timeframe,
      this.params});

  Alert.fromDocument(DocumentSnapshot doc)
      : id = doc.documentID,
        name = EnumToString.fromString(AlertName.values, doc.data['name']),
        exchange = doc.data['exchange'],
        market = doc.data['market'],
        timeframe = doc.data['timeframe'],
        params = doc.data['params'];

  Alert.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = EnumToString.fromString(AlertName.values, json['name']),
        exchange = json['exchange'],
        market = json['market'],
        timeframe = json['timeframe'],
        params = json['params'];

  static String nameFor(AlertName alertName) {
    switch (alertName) {
      case AlertName.guppy:
        return "Guppy";
      case AlertName.divergence:
        return "Divergence";
      case AlertName.price:
        return "Price";
    }
  }

  toJson() {
    var ps = params.map((k, v) =>
        MapEntry(k, enums.contains(v.runtimeType) ? EnumToString.parse(v) : v));
    return {
      'id': id,
      'exchange': exchange,
      'market': market,
      'timeframe': timeframe,
      'name': EnumToString.parse(name),
      'params': ps,
    };
  }
}
