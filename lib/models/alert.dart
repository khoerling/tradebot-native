enum AlertGuppy { green, red, grey }
enum AlertName { price, divergence, guppy }
enum AlertPrice { greater, less }

class Alert {
  String id;
  String key;
  AlertName name;
  String exchange;
  String market;
  String timeframe;
  Map<String, dynamic> params;

  Alert(
      {this.id,
      this.key,
      this.name,
      this.exchange,
      this.market,
      this.timeframe,
      this.params});

  static Alert fromMap(Map<String, dynamic> data, String id) {
    return Alert(
        id: id,
        exchange: data['exchange'],
        market: data['market'],
        timeframe: data['timeframe'],
        name: alertFrom(data['name']));
  }
}

AlertName alertFrom(String alert) {
  for (var a in AlertName.values) {
    if (a.toString() == alert) {
      return a;
    }
  }
  return null;
}
