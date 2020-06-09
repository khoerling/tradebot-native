import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:tradebot_native/components/sparkle_button.dart';
import 'package:tradebot_native/components/params.dart';
import 'package:tradebot_native/models/user.dart';
import 'package:tradebot_native/models/alert.dart';

const confettiTimer = Duration(milliseconds: 2000);

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
  String _isVisibleWith;

  @override
  void initState() {
    super.initState();
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
  didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<User>(context);
    // update ourselves
    if (user != _user) _user = user;
  }

  Future<bool> _createAlert() async {
    FocusScope.of(context).focusedChild.unfocus();
    if (_formKey.currentState.validate()) {
      if (!_alert.validate(info)) return false; // guard
      HapticFeedback.lightImpact();
      if (_isCreating) return false; // guard
      _isCreating = true;
      Timer(confettiTimer, () => _isCreating = false); // rate-limit creation
      EventEmitter.publish('confetti', 1);
      Future.delayed(Duration(milliseconds: 0), () async {
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
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SearchChoices.single(
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
                    setState(() {
                      _alert.exchange = value;
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
                ),
                _alert.exchange != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Expanded(
                                child: SearchChoices.single(
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
                                    setState(() => _alert.timeframe = value);
                                    _alert.timeframe = value;
                                  },
                                  isExpanded: true,
                                ))
                          ])
                    : Container(),
                _alert.exchange != null && _alert.market != null
                    ? Params(alert: _alert)
                    : Container(),
                Padding(
                    padding: EdgeInsets.only(top: 75.0),
                    child: SparkleButton(
                      onPressed: _createAlert,
                      title: 'CREATE ALERT',
                    )),
              ])),
    );
  }

  bool info(title, message) {
    const displayIconFor = 100;
    final displayFor = Duration(milliseconds: displayIconFor) + confettiTimer;
    if (_isVisibleWith == null || _isVisibleWith != title) {
      // error, so--
      _isVisibleWith = title;
      EventEmitter.publish('hideBottomNavigation', displayFor);
      Timer(
          Duration(milliseconds: displayIconFor),
          () => Flushbar(
                titleText: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white.withOpacity(.95),
                  ),
                ),
                messageText: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white.withOpacity(.85),
                  ),
                ),
                backgroundColor:
                    Color.fromRGBO(20, 20, 20, 1), // slightly lighter
                forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                icon: Icon(
                  Icons.visibility,
                  color: Colors.white,
                ),
                flushbarPosition: FlushbarPosition.BOTTOM,
                flushbarStyle: FlushbarStyle.GROUNDED,
                duration: displayFor,
                isDismissible: true,
              )
                ..onStatusChanged = (FlushbarStatus status) {
                  switch (status) {
                    case FlushbarStatus.SHOWING:
                      {
                        break;
                      }
                    case FlushbarStatus.IS_APPEARING:
                      {
                        break;
                      }
                    case FlushbarStatus.IS_HIDING:
                      {
                        break;
                      }
                    case FlushbarStatus.DISMISSED:
                      {
                        _isVisibleWith = null;
                        break;
                      }
                  }
                }
                ..show(context));
    }
    return true;
  }
}
