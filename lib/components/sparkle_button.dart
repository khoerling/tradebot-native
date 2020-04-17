import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tradebot_native/components/button.dart';

class SparkleButton extends StatefulWidget {
  SparkleButton({Key key, @required this.onPressed, this.title})
      : super(key: key);
  final String title;
  final Function onPressed;

  @override
  _SparkleButtonState createState() => _SparkleButtonState();
}

enum ScoreWidgetStatus { HIDDEN, BECOMING_VISIBLE, VISIBLE, BECOMING_INVISIBLE }

class _SparkleButtonState extends State<SparkleButton>
    with TickerProviderStateMixin {
  double _sparklesAngle = 0.0;
  ScoreWidgetStatus _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
  final duration = Duration(milliseconds: 200);
  final oneSecond = Duration(seconds: 1);
  Random random;
  Timer holdTimer, scoreOutETA;
  AnimationController scoreInAnimationController,
      scoreOutAnimationController,
      scoreSizeAnimationController,
      sparklesAnimationController;
  Animation scoreOutPositionAnimation, sparklesAnimation;

  initState() {
    super.initState();
    random = Random();
    scoreInAnimationController =
        AnimationController(duration: Duration(milliseconds: 50), vsync: this);
    scoreInAnimationController.addListener(() {
      setState(() {}); // Calls render function
    });

    scoreOutAnimationController =
        AnimationController(vsync: this, duration: duration);
    scoreOutPositionAnimation = Tween(begin: 100.0, end: 150.0).animate(
        CurvedAnimation(
            parent: scoreOutAnimationController, curve: Curves.easeOut));
    scoreOutPositionAnimation.addListener(() {
      setState(() {});
    });
    scoreOutAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
      }
    });

    scoreSizeAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    scoreSizeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        scoreSizeAnimationController.reverse();
      }
    });
    scoreSizeAnimationController.addListener(() {
      setState(() {});
    });

    sparklesAnimationController =
        AnimationController(vsync: this, duration: duration);
    sparklesAnimation = CurvedAnimation(
        parent: sparklesAnimationController, curve: Curves.easeIn);
    sparklesAnimation.addListener(() {
      setState(() {});
    });
  }

  dispose() {
    super.dispose();
    scoreInAnimationController.dispose();
    scoreOutAnimationController.dispose();
  }

  void increment(Timer t) {
    scoreSizeAnimationController.forward(from: 0.0);
    sparklesAnimationController.forward(from: 0.0);
    setState(() {
      _sparklesAngle = random.nextDouble() * (2 * pi);
    });
  }

  void onTapDown(TapDownDetails tap) async {
    if (holdTimer != null) return; // guard
    var res = await widget.onPressed();
    if (!res) return; // guard
    // User pressed the button. This can be a tap or a hold.
    if (scoreOutETA != null) {
      scoreOutETA.cancel(); // We do not want the score to vanish!
    }
    if (_scoreWidgetStatus == ScoreWidgetStatus.BECOMING_INVISIBLE) {
      // We tapped down while the widget was flying up. Need to cancel that animation.
      scoreOutAnimationController.stop(canceled: true);
      _scoreWidgetStatus = ScoreWidgetStatus.VISIBLE;
    } else if (_scoreWidgetStatus == ScoreWidgetStatus.HIDDEN) {
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_VISIBLE;
      scoreInAnimationController.forward(from: 0.0);
    }
    increment(null); // Take care of tap
    holdTimer = Timer.periodic(duration, increment); // Takes care of hold
    Timer(Duration(milliseconds: 1000), () {
      holdTimer.cancel();
      holdTimer = null;
      scoreOutAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    });
  }

  void onTapUp(TapUpDetails tap) {
    // User removed his finger from button.
    scoreOutETA = Timer(oneSecond, () {
      scoreOutAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    });
    holdTimer.cancel();
    holdTimer = null;
  }

  Widget getScoreButton() {
    var scorePosition = 0.0;
    var scoreOpacity = 0.0;
    var extraSize = 0.0;
    switch (_scoreWidgetStatus) {
      case ScoreWidgetStatus.HIDDEN:
        break;
      case ScoreWidgetStatus.BECOMING_VISIBLE:
      case ScoreWidgetStatus.VISIBLE:
        scorePosition = scoreInAnimationController.value * 100;
        scoreOpacity = scoreInAnimationController.value;
        extraSize = scoreSizeAnimationController.value * 3;
        break;
      case ScoreWidgetStatus.BECOMING_INVISIBLE:
        scorePosition = scoreOutPositionAnimation.value;
        scoreOpacity = 1.0 - scoreOutAnimationController.value;
    }

    var stackChildren = <Widget>[];

    var firstAngle = _sparklesAngle;
    var sparkleRadius = (sparklesAnimationController.value * 50);
    var sparklesOpacity = (1 - sparklesAnimation.value);

    for (int i = 0; i < 5; ++i) {
      var currentAngle = (firstAngle + ((2 * pi) / 5) * (i));
      var sparklesWidget = Positioned(
        child: Transform.rotate(
            angle: currentAngle - pi / 2,
            child: Opacity(
                opacity: sparklesOpacity,
                child: Image.asset(
                  "assets/images/sparkles.png",
                  width: 14.0,
                  height: 14.0,
                ))),
        left: (sparkleRadius * cos(currentAngle)) + 20,
        top: (sparkleRadius * sin(currentAngle)) + 20,
      );
      stackChildren.add(sparklesWidget);
    }

    stackChildren.add(Opacity(
        opacity: scoreOpacity,
        child: Container(
            height: 50.0 + extraSize,
            width: 50.0 + extraSize,
            child: Center(
              child: Icon(Icons.visibility, color: Colors.white, size: 50),
            ))));

    var elm = Positioned(
        child: Stack(
          alignment: FractionalOffset.center,
          overflow: Overflow.visible,
          children: stackChildren,
        ),
        bottom: scorePosition);
    return elm;
  }

  Widget getClapButton() {
    // Using custom gesture detector because we want to keep increasing the claps
    // when user holds the button.

    var extraSize = 0.0;
    if (_scoreWidgetStatus == ScoreWidgetStatus.VISIBLE ||
        _scoreWidgetStatus == ScoreWidgetStatus.BECOMING_VISIBLE) {
      extraSize = scoreSizeAnimationController.value * 3;
    }
    return GestureDetector(
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      child:
          // Container(
          //   height: 60.0 + extraSize ,
          //   width: 60.0 + extraSize,
          //   padding:  EdgeInsets.all(10.0),
          //   decoration:  BoxDecoration(
          //       border:  Border.all(color: Colors.pink, width: 1.0),
          //       color: Colors.white,
          //   ),
          //   )
          //   child:
          Button(
              onPressed: () => true,
              child: Text(
                "CREATE ALERT",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Stack(
            alignment: FractionalOffset.center,
            overflow: Overflow.visible,
            children: <Widget>[
              getScoreButton(),
              getClapButton(),
            ],
          )),
    ]);
  }
}
