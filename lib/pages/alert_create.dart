import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:search_choices/search_choices.dart';
import 'package:tradebot_native/components/button.dart';
import 'package:tradebot_native/components/params.dart';
import 'package:tradebot_native/models/alert.dart';

// TODO
// - divergence, look for bullish or bearish + thresholds, --gap = 1 candle up to 50

class AlertCreate extends StatefulWidget {
  const AlertCreate({
    Key key,
  }) : super(key: key);
  @override
  _CreateAlert createState() => _CreateAlert();
}

class _CreateAlert extends State<AlertCreate> {
  final _formKey = GlobalKey<FormState>();
  final alert = Alert(name: AlertName.price, params: {});
  final db = Firestore.instance;
  var exchanges = [], markets = [], timeframes = [];
  String _isVisibleWith;

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
        warn('Exchanges are Down', 'Try again later!');
    }).timeout(Duration(seconds: 3),
        onTimeout: () => warn('Internet Connection', 'Are you online?',
            error: 'Try again, later!'));
  }

  _fetchMarkets(String exchange) async {
    if (exchange.isEmpty) return _clearParams(); // guard
    // markets
    final HttpsCallable fetchMarkets = CloudFunctions.instance.getHttpsCallable(
      functionName: 'markets',
    );
    fetchMarkets.call({'exchange': alert.exchange}).then((res) {
      var data = res.data;
      if (data['success']) {
        // reset & translate timeframe into an array for selection
        timeframes.clear();
        data['timeframes'].forEach((k, v) {
          timeframes.add([k, v]);
        });
        setState(() {
          markets = data['markets'];
          alert.timeframe = timeframes?.last[0] ?? '';
        });
        if (markets.length < 1)
          warn(alert.exchange.toUpperCase(), 'No active markets!');
      } else {
        _clearParams();
        var err = data['error'];
        warn("${exchange.toUpperCase()} is Offline", 'Choose another exchange!',
            error: err.containsKey('name') ? err['name'] : ''); // guard
      }
    });
  }

  _clearParams() {
    // reset
    setState(() {
      alert.params = {};
    });
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

  _createAlert() async {
    // push alert to firebase
    if (test(alert.exchange == null, 'Select an Exchange!',
        'Which Exchange should this alert track?')) return;
    if (test(alert.market == null, 'Select a Market!',
        'We recommend also choosing a candle timeframe.')) return;
    if (_formKey.currentState.validate()) {
      var params = alert.params;
      switch (alert.name) {
        case AlertName.price:
          {
            var amount = params['price_amount'],
                horizon = params['price_horizon'];
            if (test(amount == null || amount == 0.0, 'Enter a Price!',
                'Greater or Less than what price?')) return;
            if (test(horizon == null, 'Select a Price Horizon!',
                "Greater or Less than ${amount}?")) return;
          }
          break;
        case AlertName.guppy:
          {
            if (test(params['guppy'] == null, 'Select a Color!',
                'What color signal should be alerted?')) return;
          }
          break;
      }
      HapticFeedback.lightImpact();
      EventEmitter.publish('confetti', 1);
      try {
        alert.created = DateTime.now();
        DocumentReference ref =
            await db.collection("alerts").add(alert.toJson());
        // success, so--
        _clearParams();
        print(ref.documentID);
      } catch (e) {
        print("Error creating alert $e");
      }
    } else {
      print('Invalid form');
    }
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
                  items: exchanges
                      .map((e) => DropdownMenuItem(
                          child: Text(e.toString().toUpperCase()),
                          value: e.toString()))
                      .toList(),
                  value: alert.exchange,
                  hint: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 14.0),
                    child: Text("Select Exchange"),
                  ),
                  searchHint: "Select Exchange",
                  onClear: () => setState(() => alert.market = null),
                  onChanged: (value) {
                    setState(() {
                      alert.exchange = value;
                    });
                    if (value != null)
                      _fetchMarkets(value);
                    else
                      _clearParams();
                  },
                  isExpanded: true,
                ),
                alert.exchange != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Expanded(
                                child: SearchChoices.single(
                              items: markets
                                  .map((e) => DropdownMenuItem(
                                      child: Text(e['symbol'].toString()),
                                      value: e['id'].toString()))
                                  .toList(),
                              value: alert.market,
                              hint: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 14.0),
                                child: Text("Select Market"),
                              ),
                              onClear: _clearParams,
                              searchHint: "Select Market",
                              onChanged: (value) {
                                setState(() => alert.market = value);
                                alert.market = value;
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
                                  value: alert.timeframe,
                                  hint: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 14.0),
                                    child: Text("Time"),
                                  ),
                                  searchHint: "Select Candle Timeframe",
                                  displayClearIcon: false,
                                  onChanged: (value) {
                                    setState(() => alert.timeframe = value);
                                    alert.timeframe = value;
                                  },
                                  isExpanded: true,
                                ))
                          ])
                    : Container(),
                alert.exchange != null &&
                        alert.market != null &&
                        alert.market != ''
                    ? Params(alert: alert)
                    : Container(),
                Padding(
                    padding: EdgeInsets.only(top: 75.0),
                    child: Button(
                        onPressed: _createAlert,
                        child: Text(
                          "CREATE ALERT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
              ])),
    );
  }

  bool test(condition, title, message) {
    if (condition) return info(title, message);
    return false;
  }

  bool info(title, message) {
    const displayFor = Duration(seconds: 3);
    if (_isVisibleWith == null || _isVisibleWith != title) {
      // error, so--
      EventEmitter.publish('hideBottomNavigation', displayFor);
      _isVisibleWith = title;
      Flushbar(
        titleText: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.black.withOpacity(.95),
          ),
        ),
        messageText: Text(
          message,
          style: TextStyle(
            fontSize: 13.0,
            color: Colors.black.withOpacity(.85),
          ),
        ),
        backgroundColor: Colors.white,
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
        icon: Icon(
          Icons.visibility,
          color: Colors.black,
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
                _isVisibleWith = null;
                break;
              }
            case FlushbarStatus.DISMISSED:
              {
                _isVisibleWith = null;
                break;
              }
          }
        }
        ..show(context);
    }
    return true;
  }
}
