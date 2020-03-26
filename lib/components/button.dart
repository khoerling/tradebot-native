import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({Key key, this.child, this.onPressed}) : super(key: key);
  final Widget child;
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Theme.of(context).backgroundColor,
      highlightedBorderColor: Colors.white,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 20.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
