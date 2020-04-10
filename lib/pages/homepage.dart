import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/components/bottom_navigation.dart';
import 'package:tradebot_native/components/background.dart';

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
  List<String> tokens = [];

  @override
  void initState() {
    super.initState();

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

    tokens.add(EventEmitter.subscribe('confetti', (_) => doConfetti()));
  }

  bool _keyboardIsVisible() {
    // immediately show & hide based on keyboard position
    bool isVisible = !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    if (!isVisible) HapticFeedback.lightImpact();
    return isVisible;
  }

  @override
  void dispose() {
    _faders.forEach((controller) => controller.dispose());
    tokens.forEach((token) => EventEmitter.unsubscribe(token));
    _hide.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
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
    Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      HapticFeedback.heavyImpact();
      Timer(Duration(milliseconds: 250), () {
        HapticFeedback.lightImpact();
        timer.cancel();
      });
    });
    _faders[_currentIndex].reverse();
    Future.delayed(Duration(seconds: 2), () {
      _faders[_currentIndex].forward();
      _hide.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    selectPage(index) {
      setState(() {
        _currentIndex = index;
      });
    }

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

class ViewNavigatorObserver extends NavigatorObserver {
  ViewNavigatorObserver(this.onNavigation);

  final VoidCallback onNavigation;

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }

  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }
}

class RootPage extends StatelessWidget {
  const RootPage({Key key, this.page}) : super(key: key);

  final TPage page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(child: page.child),
    );
  }
}
