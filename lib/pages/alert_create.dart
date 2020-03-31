import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:search_choices/search_choices.dart';
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

class AlertCreate extends StatefulWidget {
  const AlertCreate({
    Key key,
  }) : super(key: key);
  @override
  _CreateAlert createState() => _CreateAlert();
}

class _CreateAlert extends State<AlertCreate> {
  final _formKey = GlobalKey();
  final _alert = Alert();
  var exchanges = [], exchange;
  var markets = [], market;
  var timeframes = [], timeframe;

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
        _renderAlert('Exchanges are Down', 'Try again later!');
    }).timeout(Duration(seconds: 4),
        onTimeout: () => _renderAlert('Internet Connection', 'Are you online?',
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
        // reset & translate timeframe into an array for selection
        Map tf = data['timeframes'];
        timeframes.clear();
        tf.forEach((k, v) {
          timeframes.add([k, v]);
        });
        setState(() {
          markets = data['markets'];
          timeframe = timeframes?.last[0] ?? '';
        });
        if (markets.length < 1)
          _renderAlert(exchange.toUpperCase(), 'No active markets!');
      } else {
        _clearMarket();
        var error = data['error'];
        _renderAlert(
            "${exchange.toUpperCase()} is Offline", 'Choose another exchange!',
            error: error.containsKey('name') ? error['name'] : ''); // guard
      }
    });
  }

  _clearMarket() {
    setState(() => market = ''); // reset
  }

  Future<void> _renderAlert(title, msg, {error = ''}) async {
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
    return Container(
        child: SizedBox.expand(
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SearchChoices.single(
                  items: exchanges
                      .map((e) => DropdownMenuItem(
                          child: Text(e.toString().toUpperCase()),
                          value: e.toString()))
                      .toList(),
                  value: exchange,
                  hint: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 14.0),
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
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                            Expanded(
                                child: SearchChoices.single(
                              items: markets
                                  .map((e) => DropdownMenuItem(
                                      child: Text(e['symbol'].toString()),
                                      value: e['id'].toString()))
                                  .toList(),
                              value: market,
                              hint: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 14.0),
                                child: Text("Select Market"),
                              ),
                              searchHint: "Select Market",
                              onChanged: (value) {
                                setState(() => market = value);
                              },
                              isExpanded: true,
                            )),
                            Container(
                                width: 100,
                                child: SearchChoices.single(
                                  items: timeframes
                                      .map((t) => DropdownMenuItem(
                                          child: Text(t[0].toString()),
                                          value: t[0].toString()))
                                      .toList(),
                                  value: timeframe,
                                  hint: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 14.0),
                                    child: Text("Time"),
                                  ),
                                  searchHint: "Select Candle Timeframe",
                                  displayClearIcon: false,
                                  onChanged: (value) =>
                                      setState(() => timeframe = value),
                                  isExpanded: true,
                                ))
                          ])
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
