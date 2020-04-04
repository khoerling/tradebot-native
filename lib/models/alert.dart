import 'package:firebase_database/firebase_database.dart';

enum AlertName { price, divergence, guppy }
enum AlertPrice { greater, less }
enum AlertGuppy { green, red, grey }

class Alert {
  String key = '';
  String exchange = '';
  String market = '';
  String timeframe = '';
  AlertName name = AlertName.price;
  Map<String, dynamic> params = {};

  Alert() : super();

  Alert.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        exchange = snapshot.value['exchange'],
        market = snapshot.value['market'],
        timeframe = snapshot.value['timeframe'],
        name = snapshot.value['name'],
        params = snapshot.value['params'];

  toJson() {
    return {
      'exchange': exchange,
      'market': market,
      'timeframe': timeframe,
      'name': name.index,
      'params': params,
    };
  }
}
