import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:tradebot_native/models/alert.dart';
import 'package:tradebot_native/components/button.dart';
import 'package:tradebot_native/components/params.dart';

// TODO Replace with object model.
// try firebase only, cache with ccxt for market & exchange
// timeframe:  1H, 1M, 5M, 2H, 1D, 4W, (integer:letter)
// timeframe is not normalized, must come from exchange!  ccxt shows timeframes, use keys with api
// 5 alerts
// - horizontal, PRICE alert takes price input, can be directional, take up or down, > or <, run 2 alerts for both
// - guppy, did it turn green, grey or red
// - divergence, look for bullish or bearish + thresholds, --gap = 1 candle up to 50
// -

class CreateAlert extends StatefulWidget {
  const CreateAlert({
    Key key,
  }) : super(key: key);
  @override
  _CreateAlert createState() => _CreateAlert();
}

class _CreateAlert extends State<CreateAlert> {
  var exchanges = [], exchange;
  var markets = [], market;
  var timeframes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchExchanges());
  }

  _fetchExchanges() async {
    // exchanges
    final HttpsCallable fetchExchanges =
        CloudFunctions.instance.getHttpsCallable(
      functionName: 'exchanges',
    );
    fetchExchanges.call().then((res) {
      var data = res.data;
      if (data['success'])
        setState(() => exchanges = data['exchanges']);
      else
        _alert('Exchanges are Down', 'Try again later!');
    }).timeout(Duration(seconds: 4),
        onTimeout: () => _alert('Internet Connection', 'Are you online?',
            error: 'Try again, later!'));
  }

  _fetchMarkets(String exchange) async {
    if (exchange.isEmpty) return _clearMarket(); // guard
    // markets
    final HttpsCallable fetchMarkets = CloudFunctions.instance.getHttpsCallable(
      functionName: 'markets',
    );
    fetchMarkets.call({'exchange': exchange}).then((res) {
      var data = res.data;
      if (data['success']) {
        setState(() {
          markets = data['markets'];
          timeframes = data['timeframes'];
        });
        if (markets.length < 1)
          _alert(exchange.toUpperCase(), 'No active markets!');
      } else {
        _clearMarket();
        var error = data['error'];
        _alert(
            "${exchange.toUpperCase()} is Offline", 'Choose another exchange!',
            error: error.containsKey('name') ? error['name'] : ''); // guard
      }
    });
  }

  _clearMarket() {
    setState(() => market = ''); // reset
  }

  Future<void> _alert(title, msg, {error = ''}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
                Text('', style: TextStyle(fontSize: 5)),
                Text(error,
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('GOT IT'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(market);
    return Container(
        child: SizedBox.expand(
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SearchableDropdown.single(
                  items: exchanges
                      .map((e) => DropdownMenuItem(
                          child: Text(e.toString().toUpperCase()),
                          value: e.toString()))
                      .toList(),
                  value: exchange,
                  hint: Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                    child: Text("Select Exchange"),
                  ),
                  searchHint: "Select Exchange",
                  onChanged: (value) {
                    setState(() {
                      exchange = value;
                    });
                    if (value != null)
                      _fetchMarkets(value);
                    else
                      _clearMarket();
                  },
                  isExpanded: true,
                ),
                exchange != null
                    ? SearchableDropdown.single(
                        items: markets
                            // .where((m) => m && m['active'])
                            .map((e) => DropdownMenuItem(
                                child: Text(e['symbol'].toString()),
                                value: e['id'].toString()))
                            .toList(),
                        value: market,
                        hint: Padding(
                          padding:
                              const EdgeInsets.only(top: 25.0, bottom: 14.0),
                          child: Text("Select Market"),
                        ),
                        searchHint: "Select Market",
                        onChanged: (value) {
                          setState(() => market = value);
                        },
                        isExpanded: true,
                      )
                    : Container(),
                market != null && market != '' ? Params() : Container(),
                Padding(
                    padding: EdgeInsets.only(top: 75.0),
                    child: Button(
                        child: Text(
                      "CREATE ALERT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
              ])),
    ));
  }
}
