import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
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
  final FocusNode focusNode = FocusNode();
  final amountFormatter =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Theme.of(context).backgroundColor,
      nextFocus: true,
      actions: [
        KeyboardAction(focusNode: focusNode, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tabHeader = (String name) => Padding(
            padding: EdgeInsets.only(top: 25, bottom: 15),
            child: Text(name.toUpperCase(), style: TextStyle(fontSize: 12))),
        alert = widget.alert,
        params = alert.params;
    return DefaultTabController(
        length: 3,
        child: SizedBox(
            height: 150,
            child: Column(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white10))),
                child: Padding(
                    padding: EdgeInsets.only(top: 35.0),
                    child: TabBar(
                        indicatorColor: Colors.white10,
                        indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3),
                                width: 1.0)),
                        onTap: (i) {
                          // so we know which alert to create
                          alert.name = AlertName.values[i];
                        },
                        tabs: [
                          tabHeader('Price'),
                          tabHeader('Divergence'),
                          tabHeader('Guppy'),
                        ])),
              ),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(top: 25.0),
                      child: TabBarView(children: [
                        Row(children: <Widget>[
                          // greater or less radios
                          ...[
                            ['Greater', AlertPrice.greater],
                            ['Less', AlertPrice.less]
                          ].map((radio) => SizedBox(
                              width: 120,
                              height: 120,
                              child: LinkedLabelRadio(
                                label: radio[0],
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                value: radio[1],
                                groupValue: params['price_horizon'],
                                onChanged: (value) => setState(
                                    () => params['price_horizon'] = value),
                              ))),
                          SizedBox(
                              width: 100,
                              height: 220,
                              child: TextFormField(
                                controller: amountFormatter,
                                focusNode: focusNode,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 0.0),
                                ),
                                onChanged: (value) => setState(() =>
                                    params['price_amount'] =
                                        amountFormatter.numberValue),
                                onEditingComplete: () {
                                  focusNode.unfocus();
                                },
                              ))
                        ]),
                        // bearish and hidden checks
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                child: Row(children: <Widget>[
                              ...[
                                [
                                  'Bearish',
                                  'Default: Bullish',
                                  'divergence_bearish'
                                ],
                                [
                                  'Hidden',
                                  'Search Hidden ∇',
                                  'divergence_hidden'
                                ]
                              ].map(
                                (check) => Expanded(
                                    child: LinkedLabelCheckbox(
                                  label: check[0],
                                  subLabel: check[1],
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 1.0),
                                  value: params[check[2]] ?? false,
                                  onChanged: (value) =>
                                      setState(() => params[check[2]] = value),
                                )),
                              ),
                            ])),
                          ],
                        ),
                        // guppy alert options
                        Row(
                          children: <Widget>[
                            ...[
                              ['Green', AlertGuppy.green],
                              ['Grey', AlertGuppy.grey],
                              ['Red', AlertGuppy.red]
                            ].map((guppy) => Expanded(
                                    child: LinkedLabelRadio(
                                  label: guppy[0],
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  value: guppy[1],
                                  groupValue: params['guppy'],
                                  onChanged: (value) =>
                                      setState(() => params['guppy'] = value),
                                ))),
                          ],
                        ),
                      ])))
            ])));
  }
}
