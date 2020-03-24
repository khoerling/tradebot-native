import 'package:flutter/material.dart';
import 'package:tradebot_native/pages/list_alerts.dart';
import 'package:tradebot_native/pages/homepage.dart';

export 'account.dart';
export 'create_alert.dart';
export 'homepage.dart';
export 'list_alerts.dart';

class Page {
  const Page(this.index, this.title, this.icon, this.color);
  final int index;
  final String title;
  final IconData icon;
  final Color color;
}

const List<Page> allPages = <Page>[
  Page(0, 'CreateAlert', Icons.add, Colors.black),
  Page(1, 'ListAlerts', Icons.list, Colors.black),
  Page(2, 'Account', Icons.perm_identity, Colors.black),
];

class PagesView extends StatefulWidget {
  const PagesView({Key key, this.page, this.onNavigation}) : super(key: key);

  final Page page;
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
            print(settings.name);
            switch (settings.name) {
              case '/':
                return RootPage(page: widget.page);
              case '/list':
                return ListAlerts(page: widget.page);
            }
          },
        );
      },
    );
  }
}
