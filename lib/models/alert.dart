import 'package:flutter/foundation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradebot_native/models/user.dart';

enum AlertGuppy { green, red, grey }
enum AlertName { price, divergence, guppy }
enum AlertPrice { greater, less }

// used to enum -> string <- enum
const enums = [AlertGuppy, AlertName, AlertPrice];

class Alert with ChangeNotifier {
  String id;
  String key;
  AlertName name;
  String exchange;
  Map market;
  String timeframe;
  List<DateTime> alerted = [];
  bool isAlerted = false;
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
      this.alerted = const [],
      this.isAlerted = false,
      this.created,
      this.updated,
      this.params});

  factory Alert.fromMap(Map data) {
    try {
      var alerted = data['alerted'];
      return Alert(
          id: data['id'],
          name: EnumToString.fromString(AlertName.values, data['name']),
          exchange: data['exchange'],
          market: data['market'],
          timeframe: data['timeframe'],
          isAlerted: data['isAlerted'] ?? false,
          alerted: alerted
                  ?.map((a) => a is String ? DateTime.parse(a) : a.toDate())
                  ?.toList()
                  ?.cast<DateTime>() ??
              [],
          created: User.timeFor('created', data),
          updated: User.timeFor('updated', data),
          params: data['params'] ?? {});
    } catch (e) {
      print('Error Alert.fromMap $e');
    }
    return Alert();
  }

  Alert.fromDocument(DocumentSnapshot doc)
      : id = doc.documentID,
        name = EnumToString.fromString(AlertName.values, doc.data['name']),
        exchange = doc.data['exchange'],
        market = doc.data['market'],
        timeframe = doc.data['timeframe'],
        isAlerted = doc.data['isAlerted'],
        alerted = doc.data['alerted'] ?? [],
        created = User.timeFor('created', doc.data),
        updated = User.timeFor('updated', doc.data),
        params = doc.data['params'] ?? {};

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

  bool validate(onError) {
    var tester = (condition, title, message, onError) {
      if (condition) return onError(title, message);
      return false;
    };
    var test = (c, t, m) => tester(c, t, m, onError);
    if (test(exchange == null, 'Select an Exchange!',
        'Which Exchange should this alert track?')) return false;
    if (test(market == null, 'Select a Market!',
        'We recommend also choosing a candle timeframe.')) return false;
    if (test(timeframe == null, 'Select a Timeframe!',
        'Select a candle timeframe for this alert.')) return false;
    switch (name) {
      case AlertName.price:
        {
          var amount = params['price_amount'],
              horizon = params['price_horizon'];
          if (test(amount == null || amount == 0.0, 'Enter a Price!',
              'Greater or Less than what price?')) return false;
          if (test(horizon == null, 'Select a Price Horizon!',
              "Greater or Less than $amount?")) return false;
        }
        break;
      case AlertName.guppy:
        {
          if (test(params['guppy'] == null, 'Select a Color!',
              'Which color signal should be alerted?')) return false;
        }
        break;
      case AlertName.divergence:
        {
          // no test needs to happen
        }
        break;
    }
    return true;
  }

  resetAlert() {
    isAlerted = false;
    updated = DateTime.now();
    notifyListeners();
  }

  toJson() {
    var ps = params.map((k, v) =>
        MapEntry(k, enums.contains(v.runtimeType) ? EnumToString.parse(v) : v));
    return {
      'id': id,
      'exchange': exchange,
      'market': market,
      'timeframe': timeframe,
      'isAlerted': isAlerted ?? false,
      'alerted': alerted?.map((a) => a.toIso8601String())?.toList() ?? [],
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'name': EnumToString.parse(name),
      'params': ps,
    };
  }
}
