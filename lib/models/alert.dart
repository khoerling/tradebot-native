import 'package:enum_to_string/enum_to_string.dart';

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

  toJson() {
    var ps = params.map((k, v) => MapEntry(k, enums.contains(v.runtimeType) ? EnumToString.parse(v) : v));
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
