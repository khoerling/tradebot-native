import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class Params extends StatefulWidget {
  final Widget child;
  Params({Key key, this.child}) : super(key: key);

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
                        Expanded(
                            child: Text(
                                'Alert on price above or below a horizontal level')),
                        Expanded(
                            child: Row(children: <Widget>[
                          Expanded(
                              child: ListTile(
                            title: const Text('Greater'),
                            leading: Radio(
                                // value: SingingCharacter.lafayette,
                                // groupValue: _character,
                                // onChanged: (SingingCharacter value) {
                                //   setState(() { _character = value; });
                                // },
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
                        ListTile(
                          title: const Text('Less'),
                          leading: Radio(
                              //   value: SingingCharacter.jefferson,
                              //   groupValue: _character,
                              //   onChanged: (SingingCharacter value) {
                              //     setState(() { _character = value; });
                              //   },
                              ),
                        ),
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
                                Expanded(child:
                          ListTile(
                            title: const Text('Hidden Divergence'),
                            // value: timeDilation != 1.0,
                            // onChanged: (bool value) {
                            //   setState(() { timeDilation = value ? 10.0 : 1.0; });
                            // },
                          ),
                        ),
                        Expanded(child:
                          ListTile(
                            title: const Text('Use Bearish (default: Bullish)'),
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
                          Expanded(
                              child: Text('Alert When Guppy EMAs Turn')),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: ListTile(
                                  title: const Text('Green', style: TextStyle(fontSize: 8, wordSpacing: -10)),
                                  leading: Radio(
                                      // value: SingingCharacter.lafayette,
                                      // groupValue: _character,
                                      // onChanged: (SingingCharacter value) {
                                      //   setState(() { _character = value; });
                                      // },
                                      ),
                                )),
                                Expanded(
                                    child: ListTile(
                                  title: const Text('Grey'),
                                  leading: Radio(
                                      // value: SingingCharacter.lafayette,
                                      // groupValue: _character,
                                      // onChanged: (SingingCharacter value) {
                                      //   setState(() { _character = value; });
                                      // },
                                      ),
                                )),
                                Expanded(
                                    child: ListTile(
                                  title: const Text('Red'),
                                  leading: Radio(
                                      // value: SingingCharacter.lafayette,
                                      // groupValue: _character,
                                      // onChanged: (SingingCharacter value) {
                                      //   setState(() { _character = value; });
                                      // },
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
