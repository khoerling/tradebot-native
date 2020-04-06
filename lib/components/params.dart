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
  final money =
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
        params = widget.alert.params;
    return DefaultTabController(
        length: 3,
        child: SizedBox(
            height: 200,
            child: Column(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white10))),
                child: Padding(
                    padding: EdgeInsets.only(top: 35.0),
                    child: TabBar(
                        indicatorColor: Colors.white10,
                        indicator: UnderlineTabIndicator(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0)),
                        onTap: (i) {
                          // so we know which alert to create
                          widget.alert.name = AlertName.values[i];
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
                  SizedBox(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                            child: Row(children: <Widget>[
                          Expanded(
                              child: LinkedLabelRadio(
                            label: 'Greater',
                            padding: EdgeInsets.symmetric(horizontal: 1.0),
                            value: AlertPrice.greater,
                            groupValue: params['price_horizon'],
                            onChanged: (value) =>
                                setState(() => params['price_horizon'] = value),
                          )),
                          Expanded(
                                child:
                                KeyboardActions(
                                  config: _buildConfig(context),
                                  child: 
                                TextField(
                                    controller: money,
                                    focusNode: focusNode,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () {
                                      focusNode.unfocus();
},
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false))),
                          )
                        ])),
                        Expanded(
                            child: Row(children: <Widget>[
                          Expanded(
                              child: LinkedLabelRadio(
                            label: 'Less',
                            padding: EdgeInsets.symmetric(horizontal: 1.0),
                            value: AlertPrice.less,
                            groupValue: params['price_horizon'],
                            onChanged: (value) =>
                                setState(() => params['price_horizon'] = value),
                          )),
                          Expanded(child: Container())
                        ])),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                            child: Row(children: <Widget>[
                          Expanded(
                              child: LinkedLabelCheckbox(
                            label: 'Bearish',
                            subLabel: 'default: bullish',
                            padding: EdgeInsets.symmetric(horizontal: 1.0),
                            value: params['divergence_bearish'] ?? false,
                            onChanged: (value) => setState(
                                () => params['divergence_bearish'] = value),
                          )),
                          Expanded(
                            child: LinkedLabelCheckbox(
                              label: 'Hidden',
                              subLabel: 'search hidden ∇',
                              padding: EdgeInsets.symmetric(horizontal: 1.0),
                              value: params['divergence_hidden'] ?? false,
                              onChanged: (value) => setState(
                                  () => params['divergence_hidden'] = value),
                            ),
                          ),
                        ])),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 400,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                              child: Row(children: <Widget>[
                            Expanded(
                                child: LinkedLabelRadio(
                              label: 'Green',
                              padding: EdgeInsets.symmetric(horizontal: 1.0),
                              value: AlertGuppy.green,
                              groupValue: params['guppy'],
                              onChanged: (value) =>
                                  setState(() => params['guppy'] = value),
                            )),
                            Expanded(
                                child: LinkedLabelRadio(
                              label: 'Grey',
                              padding: EdgeInsets.symmetric(horizontal: 1.0),
                              value: AlertGuppy.grey,
                              groupValue: params['guppy'],
                              onChanged: (value) =>
                                  setState(() => params['guppy'] = value),
                            )),
                            Expanded(
                              child: LinkedLabelRadio(
                                label: 'Red',
                                padding: EdgeInsets.symmetric(horizontal: 1.0),
                                value: AlertGuppy.red,
                                groupValue: params['guppy'],
                                onChanged: (value) =>
                                    setState(() => params['guppy'] = value),
                              ),
                            ),
                          ])),
                        ],
                      )),
                ]),
              ))
            ])));
  }
}
