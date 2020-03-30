import 'package:firebase_database/firebase_database.dart';

enum Horizon { greater, less }
enum Name { price, divergence, guppy }
enum Guppy { green, red, grey }

class Alert {
  String key;
  String exchange;
  String market;
  String timeframe;
  Name name;
  Map<Name, dynamic> params = {
    Name.price: {'horizon': Horizon, 'price': String},
    Name.divergence: {
      'bearish': bool,
      'hidden': bool,
      'thresholds': {'age': int, 'gap': String, 'peak': double}
    },
    Name.guppy: Guppy,
  };

  Alert(this.exchange, this.market, this.timeframe, this.name, this.params);

  Alert.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        exchange = snapshot.value['exchange'],
        market = snapshot.value['market'],
        timeframe = snapshot.value['timeframe'],
        name = snapshot.value['name'],
        params = snapshot.value['params'];

  toJson() {
    return {
      exchange: exchange,
      market: market,
      timeframe: timeframe,
      name: name,
      params: params,
    };
  }
}
