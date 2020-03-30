import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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

  @override
  void initState() {
    super.initState();

    _faders = allPages.map<AnimationController>((TPage destination) {
      return AnimationController(
          vsync: this, duration: Duration(milliseconds: 250));
    }).toList();
    _faders[_currentIndex].value = 1.0;
    _pageKeys = List<Key>.generate(allPages.length, (int index) => GlobalKey())
        .toList();
    _hide =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  bool _keyboardIsVisible() {
    // immediately show & hide based on keyboard position
    bool isVisible = !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    if (!isVisible) HapticFeedback.lightImpact();
    return isVisible;
  }

  @override
  void dispose() {
    for (AnimationController controller in _faders) controller.dispose();
    _hide.dispose();
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
          )
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
