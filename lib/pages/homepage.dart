import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:confetti/confetti.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:provider/provider.dart';
import 'package:tradebot_native/push_notifications.dart';
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
  PushNotifications _pushNotifications = PushNotifications();
  final _random = new Random();

  @override
  void initState() {
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 2));
    _faders = allPages.map<AnimationController>((TPage destination) {
      return AnimationController(
          vsync: this, duration: Duration(milliseconds: 200));
    }).toList();
    _faders[_currentIndex].value = 1.0;
    _pageKeys = List<Key>.generate(allPages.length, (int index) => GlobalKey())
        .toList();
    _hide =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _emitterTokens
      ..add(EventEmitter.subscribe('confetti', (_) => doConfetti()))
      ..add(EventEmitter.subscribe('hideBottomNavigation', (duration) {
        _hide.reverse();
        Timer(duration + Duration(milliseconds: 1000), () => _hide.forward());
      }));
    WidgetsBinding.instance.addPostFrameCallback(initAsyncState);
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

  void initAsyncState(Duration _) async {
    return Future.wait([_pushNotifications.getToken(), initDeviceId()])
        .then((List res) {
      // TODO setup User with id & token
      // TODO save push token locally
      // TODO add token to firebase
      User user = User();
      user.pushToken = res[0];
      user.deviceId = res[1];
      // print(user.toString());
    });
  }

  Future<dynamic> initDeviceId() async {
    return await DeviceId.getID;
  }

  int _next(int min, int max) => min + _random.nextInt(max - min);

  bool _keyboardIsVisible() {
    // immediately show & hide based on keyboard position
    bool isVisible = !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    if (!isVisible) HapticFeedback.lightImpact();
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
    HapticFeedback.selectionClick();
    _hide.reverse();
    _controllerBottomCenter.play();
    Future.delayed(Duration(milliseconds: 500), () {
      _faders[_currentIndex].reverse();
      HapticFeedback.lightImpact();
    });
    Timer.periodic(Duration(milliseconds: _next(25, 150)), (Timer timer) {
      HapticFeedback.heavyImpact();
      Timer(Duration(milliseconds: _next(100, 400)), () {
        HapticFeedback.lightImpact();
        timer.cancel();
      });
    });
    Future.delayed(Duration(milliseconds: 2250), () {
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
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
          body: Stack(children: [
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
                    if (_currentIndex == destination.index) return; // guard
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
                Color.fromRGBO(38, 41, 74, 1),
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
                sizeFactor: _hide
                    .drive(CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
                axisAlignment: -1.0,
                child: _keyboardIsVisible()
                    ? null
                    : Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: BottomNavigation(
                            index: _currentIndex, onTap: selectPage)),
              ),
            ),
          ),
        ])
      ])),
    );
  }
}
