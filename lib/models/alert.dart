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
  bool isSilenced = false;
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
      this.isSilenced = false,
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
          isSilenced: data['isSilenced'] ?? false,
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
        isSilenced = doc.data['isSilenced'],
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
    if (test(exchange == null, 'Pro Tip', 'Select an Exchange for this Alert.'))
      return false;
    if (test(market == null, 'Pro Tip', 'Select a Market & Timeframe.'))
      return false;
    if (test(timeframe == null, 'Pro Tip',
        'Select a Candle Timeframe for this Alert.')) return false;
    switch (name) {
      case AlertName.price:
        {
          var amount = params['price_amount'],
              horizon = params['price_horizon'];
          if (test(
              amount == null || amount == 0.0, 'Pro Tip', 'Enter a Price.'))
            return false;
          if (test(horizon == null, 'Select a Price Horizon!',
              "More or Less than $amount?")) return false;
        }
        break;
      case AlertName.guppy:
        {
          if (test(params['guppy'] == null, 'Pro Tip',
              'Select a Guppy Color Signal to Alert.')) return false;
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

  subtitle() {
    switch (name) {
      case AlertName.guppy:
        try {
          return "Guppy is " +
              EnumToString.parse(params['guppy']).toUpperCase();
        } catch (e) {
          return "Guppy is ${params['guppy'].toUpperCase()}";
        }
        break;
      case AlertName.divergence:
        return "${params['divergence_bearish'] != null ? 'Bearish' : 'Bullish'} ${params['divergence_hidden'] != null ? 'Hidden ' : ''}Divergence";
      case AlertName.price:
        return "Price ${params['price_horizon'] == 'greater' ? '▲' : '▼'} ${params['price_amount']}";
    }

    return "";
  }

  resetAlert() {
    if (isAlerted) {
      isAlerted = false;
      // TODO set isSilenced according to User.plan
      updated = DateTime.now();
      notifyListeners();
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
      'isAlerted': isAlerted ?? false,
      'isSilenced': isSilenced ?? false,
      'alerted': alerted?.map((a) => a.toIso8601String())?.toList() ?? [],
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'name': EnumToString.parse(name),
      'params': ps,
    };
  }
}
