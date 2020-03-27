import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class Background extends StatefulWidget {
  final Widget child;
  Background({Key key, this.child}) : super(key: key);

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  List<double> _accelerometerValues;

  double xIc1 = -25.0;
  double xIc2 = 0.0;
  double xIc3 = -10.0;
  double scale = 1920 / 1080;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      _accelerometerValues = <double>[event.x, event.y, event.z];
      if ((_accelerometerValues[0] < 0)) {
        setState(() {
          xIc1 = xIc1 < 0 ? xIc1 + .5 : 0.0;
          xIc2 = xIc2 > -50 ? xIc2 - .01 : -50;
          xIc3 = xIc3 > -50 ? xIc3 - 1.2 : -50;
        });
      } else {
        setState(() {
          xIc1 = xIc1 > -50 ? xIc1 - .5 : -50;
          xIc2 = xIc2 < 0 ? xIc2 + .01 : 0.0;
          xIc3 = xIc3 < 0 ? xIc3 + 1.2 : 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: new Stack(
            children: <Widget>[
              parallax(),
            ],
          )),
    );
  }

  Widget parallax() {
    return new Stack(
      children: <Widget>[
        new Positioned(
            left: xIc1,
            bottom: 0,
            top: 0,
            child: new Container(
              width: MediaQuery.of(context).size.width + 250,
              height: MediaQuery.of(context).size.height,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.015), BlendMode.dstATop),
                      fit: BoxFit.cover,
                      image: new AssetImage('assets/images/bg.png'))),
            )),
        new Positioned(
            right: 0, left: 0, bottom: 0, top: 0, child: widget.child)
      ],
    );
  }
}