import 'package:flutter/material.dart';
import 'package:tradebot_native/pages/list_alerts.dart';
import 'package:tradebot_native/pages/create_alert.dart';
import 'package:tradebot_native/pages/account.dart';
import 'package:tradebot_native/pages/alert.dart';
import 'package:tradebot_native/pages/homepage.dart';

export 'account.dart';
export 'create_alert.dart';
export 'homepage.dart';
export 'list_alerts.dart';
export 'alert.dart';

class TPage {
  const TPage(this.index, this.title, this.icon, this.color, this.child);
  final int index;
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
}

const List<TPage> allPages = <TPage>[
  TPage(0, 'CreateAlert', Icons.add, Colors.black, CreateAlert()),
  TPage(1, 'ListAlerts', Icons.list, Colors.black, ListAlerts()),
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
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case '/':
                return RootPage(page: widget.page);
              case '/alert':
                return Alert(page: widget.page);
              case '/list':
                return ListAlerts(page: widget.page);
            }
          },
        );
      },
    );
  }
}
