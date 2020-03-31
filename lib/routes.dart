import 'package:flutter/material.dart';

class Route {
  const Route(this.index, this.title, this.icon, this.color);
  final int index;
  final String title;
  final IconData icon;
  final Color color;
}

const List<Route> Routes = <Route>[
  Route(0, 'AlertCreate', Icons.add, Colors.black),
  Route(1, 'AlertList', Icons.list, Colors.black),
  Route(2, 'Account', Icons.perm_identity, Colors.black),
];
