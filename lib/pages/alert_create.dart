import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:tradebot_native/components/sparkle_button.dart';
import 'package:tradebot_native/components/params.dart';
import 'package:tradebot_native/models/user.dart';
import 'package:tradebot_native/models/alert.dart';

const confettiTimer = Duration(milliseconds: 2000), grid = 32.0;

class AlertCreate extends StatefulWidget {
  const AlertCreate({
    Key key,
  }) : super(key: key);
  @override
  _CreateAlert createState() => _CreateAlert();
}

class _CreateAlert extends State<AlertCreate> {
  final _formKey = GlobalKey<FormState>();
  final db = Firestore.instance;
  String _token;
  User _user;
  Alert _alert = Alert(name: AlertName.price, params: {});
  List exchanges = [
    // generated using bin/cull_exchanges
    'acx', 'aofex',
    'bequant', 'bibox', 'bigone',
    'binance', 'binanceje', 'binanceus',
    'bit2c', 'bitbank', 'bitbay',
    'bitfinex', 'bitfinex2', 'bitflyer',
    'bitforex', 'bithumb', 'bitkk',
    'bitmart', 'bitmax', 'bitmex',
    'bitso', 'bitstamp', 'bitstamp1',
    'bittrex', 'bitz', 'bl3p',
    'bleutrade', 'braziliex', 'btcalpha',
    'btcbox', 'btcmarkets', 'btctradeua',
    'bw', 'bybit', 'bytetrade',
    'cex', 'chilebit', 'coinbase',
    'coinbaseprime', 'coinbasepro', 'coinex',
    'coinfalcon', 'coinfloor', 'coinmate',
    'coinone', 'coinspot', 'crex24',
    'deribit', 'digifinex', 'dsx',
    'exmo', 'exx', 'foxbit',
    'ftx', 'gateio', 'gemini',
    'hitbtc', 'hollaex', 'huobipro',
    'huobiru', 'ice3x', 'idex',
    'independentreserve', 'indodax', 'itbit',
    'kraken', 'kucoin', 'kuna',
    'lakebtc', 'latoken', 'lbank',
    'liquid', 'livecoin', 'luno',
    'lykke', 'mercado', 'mixcoins',
    'oceanex', 'okcoin', 'okex',
    'poloniex', 'rightbtc', 'southxchange',
    'stex', 'surbitcoin', 'therock',
    'tidebit', 'tidex', 'timex',
    'upbit', 'vbtc', 'whitebit',
    'yobit', 'zaif', 'zb'
  ],
      markets = [],
      timeframes = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    EventEmitter.unsubscribe(_token);
    super.dispose();
  }

  int _timeSorter(a, b) {
    var splitter = RegExp(r"([\d]+)(.+)");
    var m1 = splitter.allMatches(a), m2 = splitter.allMatches(b);
    var n1 = m1.first.group(1), n2 = m2.first.group(1);
    var d1 = m1.first.group(2), d2 = m2.first.group(2);
    if (d1 == d2) {
      // compare numerical value
      return int.parse(n1).compareTo(int.parse(n2));
    } else {
      // compare duration
      var order = ['m', 'h', 'd', 'w', 'M'];
      var i = order.indexOf(d1), j = order.indexOf(d2);
      return i.compareTo(j);
    }
  }

  _fetchMarkets(String exchange) async {
    if (exchange.isEmpty) return _clearParams(); // guard
    // markets
    final HttpsCallable fetchMarkets = CloudFunctions.instance.getHttpsCallable(
      functionName: 'markets',
    );
    fetchMarkets.call({'exchange': _alert.exchange}).then((res) {
      var data = res.data;
      if (data['success']) {
        // reset & translate timeframe into an array for selection
        timeframes.clear();
        data['timeframes'].keys.toList()
          ..sort(_timeSorter)
          ..forEach((k) {
            timeframes.add([k, data['timeframes'][k]]);
          });
        setState(() {
          markets = data['markets'];
          _alert.timeframe = timeframes?.first[0] ?? '';
        });
        if (markets.length < 1) {
          warn(_alert.exchange.toUpperCase(), 'No active markets!');
          _resetExchange();
        }
      } else {
        _clearParams();
        var err = data['error'];
        warn("${exchange.toUpperCase()} is Offline", 'Choose another exchange!',
            error: err.containsKey('name') ? err['name'] : ''); // guard
        _resetExchange();
      }
    }).timeout(Duration(seconds: 5),
        onTimeout: () => warn('Internet Connection', 'Are you online?',
            error: 'Try again, later!'));
  }

  _resetExchange() {
    setState(() {
      _alert.exchange = null;
    });
  }

  _clearParams() {
    // reset
    setState(() {
      _alert.params = {};
    });
    EventEmitter.publish('didClearParams', true);
  }

  Future<void> warn(title, msg, {error = ''}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).accentColor,
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
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
  didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<User>(context);
    // update ourselves
    if (user != _user) _user = user;
  }

  shouldCreateAlert() {
    return _alert.exchange != null &&
        _alert.market != null &&
        _alert.timeframe != null;
  }

  Future<bool> _createAlert() async {
    // immediately unfocus keyboard
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
    // validate alert
    if (_formKey.currentState.validate()) {
      if (!_alert.validate(info)) return false; // guard
      HapticFeedback.lightImpact();
      if (_isCreating) return false; // guard
      _isCreating = true;
      Timer(confettiTimer, () => _isCreating = false); // rate-limit creation
      EventEmitter.publish('confetti', 1);
      // allow animation fx to finish before adding
      Future.delayed(Duration(milliseconds: 3500), () async {
        try {
          // add alert
          _user.createAlert(_alert);
          // success, so-- reset for next
          _alert = Alert(
              name: _alert.name,
              exchange: _alert.exchange,
              market: _alert.market,
              timeframe: _alert.timeframe,
              params: {});
          _clearParams();
        } catch (e) {
          print("Error creating alert $e");
          info('Error Creating Alert', e);
        }
      });
    } else {
      print('Invalid form');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: grid, right: grid),
                child: SearchChoices.single(
                  displayClearIcon: false,
                  underline: Divider(height: 0),
                  items: [
                    for (var e in exchanges)
                      DropdownMenuItem(
                          child: Text(e.toString().toUpperCase()),
                          value: e.toString())
                  ],
                  value: _alert.exchange,
                  hint: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 14.0),
                    child: Text("Select Exchange"),
                  ),
                  searchHint: "Select Exchange",
                  onClear: () => setState(() => _alert.market = null),
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _alert.exchange = value;
                      _alert.market = null;
                    });
                    if (value != null) {
                      _fetchMarkets(value);
                      info("${_alert.exchange.toUpperCase()}!",
                          'Now, Select a Market.');
                    } else {
                      _clearParams();
                    }
                  },
                  isExpanded: true,
                )),
            Padding(
                padding: const EdgeInsets.only(left: grid, right: grid),
                child: _alert.exchange != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Expanded(
                                child: SearchChoices.single(
                              displayClearIcon: false,
                              underline: Divider(height: 0),
                              items: [
                                for (var m in markets)
                                  DropdownMenuItem(
                                      child: Text(m['symbol']), value: m)
                              ],
                              value: _alert.market,
                              hint: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 14.0),
                                child: Text("Select Market"),
                              ),
                              onClear: _clearParams,
                              searchHint: "Select Market",
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _alert.market = value);
                                _alert.market = value;
                              },
                              isExpanded: true,
                            )),
                            Container(
                                width: 100,
                                child: SearchChoices.single(
                                  underline: Divider(height: 0),
                                  items: [
                                    for (var t in timeframes)
                                      DropdownMenuItem(
                                          child: Text(t[0]), value: t[0])
                                  ],
                                  value: _alert.timeframe,
                                  hint: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 14.0),
                                    child: Text("Time"),
                                  ),
                                  searchHint: "Select Candle Timeframe",
                                  displayClearIcon: false,
                                  onChanged: (value) {
                                    HapticFeedback.lightImpact();
                                    setState(() => _alert.timeframe = value);
                                    _alert.timeframe = value;
                                  },
                                  isExpanded: true,
                                ))
                          ])
                    : Container()),
            Padding(
              padding: EdgeInsets.only(left: 0, right: 0, top: grid),
              child: _alert.exchange != null && _alert.market != null
                  ? Params(alert: _alert)
                  : Container(),
            ),
            Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 50.0),
                child: SparkleButton(
                  onPressed: _createAlert,
                  style: shouldCreateAlert()
                      ? TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.bold)
                      : TextStyle(
                          color: Theme.of(context).accentColor.withOpacity(.3),
                          fontWeight: FontWeight.bold),
                )),
          ]),
    );
  }

  info(title, body) {
    EventEmitter.publish('showInfo', {"title": title, "body": body});
  }
}
