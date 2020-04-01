import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:tradebot_native/components/linked_label_checkbox.dart';
import 'package:tradebot_native/models/alert.dart';

class Params extends StatefulWidget {
  final Alert alert;

  Params({Key key, this.alert}) : super(key: key);

  @override
  _ParamsState createState() => _ParamsState();
}

class _ParamsState extends State<Params> with SingleTickerProviderStateMixin {
  final money =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tab = (String name) => Padding(
        padding: EdgeInsets.only(top: 25, bottom: 15),
        child: Text(name.toUpperCase(), style: TextStyle(fontSize: 12)));
    return DefaultTabController(
        length: 3,
        child: SizedBox(
            height: 200,
            child: Column(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white30))),
                child: Padding(
                    padding: EdgeInsets.only(top: 35.0),
                    child: TabBar(
                        indicatorColor: Colors.white30,
                        indicator: UnderlineTabIndicator(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0)),
                        tabs: [
                          tab('Price'),
                          tab('Divergence'),
                          tab('Guppy'),
                        ])),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: TabBarView(children: [
                  SizedBox(
                    height: 400,
                    child: Column(
                      children: <Widget>[
                        Expanded(child: Text('Alert on price movement')),
                        Expanded(
                            child: Row(children: <Widget>[
                          Expanded(
                              child: ListTile(
                            title: Text('Greater'),
                            leading: Radio(
                              // value: AlertPrice.greater,
                              groupValue: widget.alert.params[AlertName.price]
                                  ['horizon'],
                              onChanged: (value) => setState(() => widget.alert
                                  .params[AlertName.price]['horizon'] = value),
                            ),
                          )),
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: TextField(
                                    controller: money,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false))),
                          )
                        ])),
                        //  ListTile(
                        //   title: Text('Less'),
                        //   leading: Radio(
                        //     value: AlertPrice.less,
                        //     groupValue: widget.alert.params[AlertName.price],
                        //     onChanged: (value) => setState(() =>
                        //         widget.alert.params[AlertName.price].horizon = value),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: Column(
                      children: <Widget>[
                        Expanded(child: Text('Alert on Divergence')),
                        Expanded(
                            child: Row(children: <Widget>[
                          // Expanded(
                          //   child:
                          //     LinkedLabelCheckbox(
                          //       label: 'Linked, tappable label text',
                          //       padding: EdgeInsets.symmetric(horizontal: 20.0),
                          //       value: widget.alert.params[AlertName.divergence].hidden,
                          //       onChanged: (value) => setState(() => widget.alert.params[AlertName.divergence].hidden = value),
                          //       // onChanged: (bool newValue) {
                          //       //   setState(() {
                          //       //       _isSelected = newValue;
                          //       //   });
                          //       // },
                          //     ),
                          //   // ListTile(
                          //   //   title: Text('Hidden Divergence'),
                          //   //   // value: timeDilation != 1.0,
                          //   //   // onChanged: (bool value) {
                          //   //   //   setState(() { timeDilation = value ? 10.0 : 1.0; });
                          //   //   // },
                          //   // ),
                          // ),
                          Expanded(
                            child: ListTile(
                              title: Text('Use Bearish (default: Bullish)'),
                              // value: timeDilation != 1.0,
                              // onChanged: (bool value) {
                              //   setState(() { timeDilation = value ? 10.0 : 1.0; });
                              // },
                            ),
                          )
                        ])),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 400,
                      child: Column(
                        children: <Widget>[
                          Expanded(child: Text('Alert When Guppy EMAs Change')),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: ListTile(
                                  title: Text('Green'),
                                  leading: Radio(
                                    value: AlertGuppy.green,
                                    groupValue:
                                        widget.alert.params[AlertName.guppy],
                                    onChanged: (value) => setState(() => widget
                                        .alert.params[AlertName.guppy] = value),
                                  ),
                                )),
                                Expanded(
                                    child: ListTile(
                                  title: Text('Grey'),
                                  leading: Radio(
                                    value: AlertGuppy.grey,
                                    groupValue:
                                        widget.alert.params[AlertName.guppy],
                                    onChanged: (value) => setState(() => widget
                                        .alert.params[AlertName.guppy] = value),
                                  ),
                                )),
                                Expanded(
                                    child: ListTile(
                                  title: Text('Red'),
                                  leading: Radio(
                                    value: AlertGuppy.red,
                                    groupValue:
                                        widget.alert.params[AlertName.guppy],
                                    onChanged: (value) => setState(() => widget
                                        .alert.params[AlertName.guppy] = value),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      )),
                ]),
              ))
            ])));
  }
}
