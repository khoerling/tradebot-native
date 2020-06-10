import 'package:flutter/material.dart';

extension CustomColorScheme on ColorScheme {
  Color get beppuTerminalBlue => const Color.fromRGBO(18, 21, 54, 1);
  Color get backgroundColor => const Color.fromRGBO(0, 0, 0, 1);
  Color get themeColor => const Color.fromRGBO(157, 67, 253, 1);
  Color get success => const Color(0xFF09B27D);
  Color get info => const Color(0xFF17a2b8);
  Color get warning => const Color(0xFFffc107);
  Color get danger => const Color(0xFFdc3545);
}
