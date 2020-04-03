import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LinkedLabelCheckbox extends StatefulWidget {
  const LinkedLabelCheckbox({
    this.label,
    this.subLabel = '',
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final String subLabel;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  _LinkedLabelCheckbox createState() => _LinkedLabelCheckbox();
}

class _LinkedLabelCheckbox extends State<LinkedLabelCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        children: <Widget>[
          ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 40.0,
              maxHeight: 80.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 20,
                    child: RichText(
                      text: TextSpan(
                        text: widget.label,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            widget.onChanged(!(widget.value ?? false));
                          },
                      ),
                    ),
                  ),
                ),
                widget.subLabel.isNotEmpty
                    ? Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: widget.subLabel,
                            style:
                                TextStyle(fontSize: 12, color: Colors.white54),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                widget.onChanged(!(widget.value ?? false));
                              },
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Switch(
            value: widget.value,
            onChanged: (bool newValue) {
              widget.onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}
