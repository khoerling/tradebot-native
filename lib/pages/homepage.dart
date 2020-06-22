import 'dart:math';
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/components/bottom_navigation.dart';
import 'package:tradebot_native/models/user.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  List<Key> _pageKeys;
  List<AnimationController> _faders;
  AnimationController _hide;
  int _currentIndex = 0;
  ConfettiController _controllerBottomCenter;
  List<String> _emitterTokens = [];
  Random _random = Random();
  Timer _timer;
  String _isVisibleWith;

  @override
  void initState() {
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 2));
    _faders = [
      for (TPage _ in allPages)
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
    ];
    _faders[_currentIndex].value = 1.0;
    _pageKeys = List<Key>.generate(allPages.length, (int index) => GlobalKey())
        .toList();
    _hide =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _emitterTokens
      ..add(EventEmitter.subscribe(
          'showInfo', (msg) => info(msg["title"], msg["body"])))
      ..add(EventEmitter.subscribe('confetti', (_) => doConfetti()))
      ..add(EventEmitter.subscribe('selectPage', (i) => selectPage(i)))
      ..add(EventEmitter.subscribe('hideBottomNavigation', (duration) {
        if (_timer != null) _timer.cancel();
        _hide.reverse();
        _timer = Timer(
            duration + Duration(milliseconds: 1000), () => _hide.forward());
      }));
    // ask for push notifications
    final user = Provider.of<User>(context, listen: false);
    Timer(Duration(milliseconds: 250), () {
      // always setup messaging
      user.requestPushToken;
      // show white statusbar
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
    super.initState();
  }

  @override
  void dispose() {
    _faders.forEach((controller) => controller.dispose());
    _emitterTokens.forEach((token) => EventEmitter.unsubscribe(token));
    _hide.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  bool _keyboardIsVisible() {
    // immediately show & hide based on keyboard position
    bool isVisible = !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    return isVisible;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // show & hide bottom bar on scroll
    if (_currentIndex == 0) return false; // guard
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            _hide.forward();
            break;
          case ScrollDirection.reverse:
            _hide.reverse();
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  doConfetti() {
    _hide.reverse();
    _controllerBottomCenter.play();
    // FIXME fade out isn't working?
    _faders[_currentIndex].reverse();
    Future.delayed(Duration(milliseconds: 3000), () {
      _faders[_currentIndex].forward();
      _hide.forward();
    });
  }

  selectPage(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Stack(children: [
              Stack(
                fit: StackFit.expand,
                children: allPages.map((TPage destination) {
                  final Widget view = FadeTransition(
                    opacity: _faders[destination.index]
                        .drive(CurveTween(curve: Curves.fastOutSlowIn)),
                    child: KeyedSubtree(
                      key: _pageKeys[destination.index],
                      child: PagesView(
                        page: destination,
                        onNavigation: () {
                          if (_currentIndex == destination.index)
                            return; // guard
                          _hide.forward();
                        },
                      ),
                    ),
                  );
                  if (destination.index == _currentIndex) {
                    _faders[destination.index].forward();
                    return view;
                  } else {
                    _faders[destination.index].reverse();
                    // ignore pointer events during transition
                    if (_faders[destination.index].isAnimating) {
                      return IgnorePointer(child: view);
                    }
                    return Offstage(child: view);
                  }
                }).toList(),
              ),
              Stack(children: [
                // bottom center
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConfettiWidget(
                    confettiController: _controllerBottomCenter,
                    blastDirection: -pi / 2,
                    emissionFrequency: 0.02,
                    numberOfParticles: 10,
                    maxBlastForce: 400,
                    minBlastForce: 50,
                    shouldLoop: false,
                    colors: [
                      Theme.of(context).accentColor,
                      Colors.grey,
                      Colors.white,
                    ],
                    gravity: 0.5,
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: ClipRect(
                    child: SizeTransition(
                      sizeFactor: _hide.drive(
                          CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
                      axisAlignment: -1.0,
                      child: _keyboardIsVisible()
                          ? null
                          : Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: user.activeAlerts.length > 0
                                  ? BottomNavigation(
                                      index: _currentIndex, onTap: selectPage)
                                  : Container()),
                    ),
                  ),
                ),
              ])
            ])),
      ),
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
                    fontSize: 17.0,
                    color: Colors.white,
                  ),
                ),
                messageText: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white.withOpacity(.85),
                  ),
                ),
                backgroundColor: Theme.of(context).accentColor,
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
