import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:tradebot_native/components/linked_label_checkbox.dart';
import 'package:tradebot_native/components/linked_label_radio.dart';
import 'package:tradebot_native/models/alert.dart';

class Params extends StatefulWidget {
  final Alert alert;

  Params({Key key, this.alert}) : super(key: key);

  @override
  _ParamsState createState() => _ParamsState();
}

class _ParamsState extends State<Params> with SingleTickerProviderStateMixin {
  String _token;
  TabController _tabController;
  List<Widget> tabs = [
    Tab(text: 'PRICE'),
    Tab(text: 'DIVERGENCE'),
    Tab(text: 'GUPPY')
  ];
  final amountFormatter =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length)
      ..addListener(() {
        // update active alert
        setAlert(_tabController.index);
      });
    _token = EventEmitter.subscribe(
        'didClearParams', (_) => amountFormatter.updateValue(0.0));
  }

  @override
  void dispose() {
    EventEmitter.unsubscribe(_token);
    _tabController.dispose();
    super.dispose();
  }

  setAlert(index) {
    widget.alert.name = AlertName.values[index];
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    var alert = widget.alert, params = alert.params;
    return Container(
        color: Colors.white.withOpacity(.03),
        child: DefaultTabController(
            length: 3,
            child: ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: SizedBox(
                        height: 210,
                        child: Column(children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Colors.white.withOpacity(0.05)))),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 5.0),
                                child: TabBar(
                                    isScrollable: true,
                                    controller: _tabController,
                                    indicator: UnderlineTabIndicator(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).accentColor,
                                            width: 1)),
                                    onTap: (i) {
                                      // so we know which alert to create
                                      setAlert(i);
                                    },
                                    tabs: tabs ?? [])),
                          ),
                          Expanded(
                              child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Row(children: <Widget>[
                                            // greater or less radios
                                            ...[
                                              ['More ▲', AlertPrice.greater],
                                              ['Less ▼', AlertPrice.less]
                                            ].map((radio) => SizedBox(
                                                width: 120,
                                                child: LinkedLabelRadio(
                                                  label: radio[0],
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                                  value: radio[1],
                                                  groupValue:
                                                      params['price_horizon'],
                                                  onChanged: (value) =>
                                                      setState(() => params[
                                                              'price_horizon'] =
                                                          value),
                                                ))),
                                          ]),
                                          Row(children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 25),
                                                child: SizedBox(
                                                    width: 150,
                                                    child: TextFormField(
                                                      // textAlign: TextAlign.center,
                                                      controller:
                                                          amountFormatter,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: "Amount",
                                                        labelStyle: TextStyle(
                                                            color: const Color(
                                                                0xFF424242)),
                                                        // border: InputBorder.none,
                                                      ),
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      onChanged: (value) =>
                                                          setState(() => params[
                                                                  'price_amount'] =
                                                              amountFormatter
                                                                  .numberValue),
                                                    )))
                                          ]),
                                        ])),
                                // bearish and hidden checks
                                Column(
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20, top: 20),
                                        child: Column(children: <Widget>[
                                          ...[
                                            [
                                              'Bearish',
                                              'Default: Bullish',
                                              'divergence_bearish'
                                            ],
                                            [
                                              'Hidden',
                                              'Search for Hidden Divergence',
                                              'divergence_hidden'
                                            ]
                                          ].map(
                                            (check) => Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20),
                                                child: SizedBox(
                                                    height: 55,
                                                    child: LinkedLabelCheckbox(
                                                      label: check[0],
                                                      subLabel: check[1],
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 1.0),
                                                      value: params[check[2]] ??
                                                          false,
                                                      onChanged: (value) =>
                                                          setState(() =>
                                                              params[check[2]] =
                                                                  value),
                                                    ))),
                                          ),
                                        ])),
                                  ],
                                ),
                                // guppy alert options
                                Column(children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 20, right: 20, top: 20),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          ...[
                                            ['Green', AlertGuppy.green],
                                            ['Grey', AlertGuppy.grey],
                                            ['Red', AlertGuppy.red]
                                          ].map((guppy) => Expanded(
                                                  child: LinkedLabelRadio(
                                                label: guppy[0],
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                value: guppy[1],
                                                groupValue: params['guppy'],
                                                onChanged: (value) => setState(
                                                    () => params['guppy'] =
                                                        value),
                                              ))),
                                        ],
                                      )),
                                ])
                              ]))
                        ]))))));
  }
}
