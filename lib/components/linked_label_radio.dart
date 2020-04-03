import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LinkedLabelRadio extends StatefulWidget {
  const LinkedLabelRadio({
    this.label,
    this.subLabel = '',
    this.padding,
    this.value,
    this.groupValue,
    this.onChanged,
  });

  final String label;
  final String subLabel;
  final EdgeInsets padding;
  final dynamic value;
  final dynamic groupValue;
  final Function onChanged;

  @override
  _LinkedLabelRadio createState() => _LinkedLabelRadio();
}

class _LinkedLabelRadio extends State<LinkedLabelRadio> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: RichText(
                    text: TextSpan(
                      text: widget.label,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          widget.onChanged(widget.value);
                        },
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
                                widget.onChanged(widget.value);
                              },
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Expanded(
            child: Radio(
              value: widget.value,
              groupValue: widget.groupValue,
              onChanged: (newValue) {
                widget.onChanged(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }
}
