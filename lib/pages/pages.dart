import 'package:flutter/material.dart';
import 'package:tradebot_native/pages/alert_list.dart';
import 'package:tradebot_native/pages/alert_create.dart';
import 'package:tradebot_native/pages/alert_detail.dart';
import 'package:tradebot_native/pages/account.dart';
import 'package:tradebot_native/components/background.dart';

export 'account.dart';
export 'homepage.dart';
export 'alert_create.dart';
export 'alert_list.dart';
export 'alert_detail.dart';

class TPage {
  const TPage(this.index, this.title, this.icon, this.color, this.child);
  final int index;
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
}

const List<TPage> allPages = <TPage>[
  TPage(0, 'AlertCreate', Icons.add, Colors.black, AlertCreate()),
  TPage(1, 'ALertList', Icons.list, Colors.black, AlertList()),
  TPage(2, '', Icons.perm_identity, Colors.black, Account()),
];

class PagesView extends StatefulWidget {
  const PagesView({Key key, this.page, this.onNavigation}) : super(key: key);

  final TPage page;
  final VoidCallback onNavigation;

  @override
  _PageViewState createState() => _PageViewState();
}

class _PageViewState extends State<PagesView> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: <NavigatorObserver>[
        ViewNavigatorObserver(widget.onNavigation),
      ],
      onGenerateRoute: (RouteSettings settings) {
        final arguments = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            var root = RootPage(page: widget.page);
            switch (settings.name) {
              case '/':
                return root;
              case '/alert':
                return AlertDetail(page: widget.page, alert: arguments);
              case '/list':
                return AlertList();
            }
            return root;
          },
        );
      },
    );
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
