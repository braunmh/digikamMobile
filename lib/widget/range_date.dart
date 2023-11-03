import 'package:flutter/material.dart';

import '../util/range.dart';
import 'incomplete_date.dart';

class RangeDateWidget extends StatefulWidget {
  @override
  RangeDateWidgetState createState() {
    return RangeDateWidgetState();
  }

  final ValueChanged<RowRangeIncompleteDate> onChanged;
  final RowRangeIncompleteDate defaultValue;
  final String labelText;

  const RangeDateWidget({
    super.key,
    required this.defaultValue,
    required this.onChanged,
    required this.labelText,
  });
}

class RangeDateWidgetState extends State<RangeDateWidget> {
  late RowRangeIncompleteDate _value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: IncompleteDateWidget(
            labelText: widget.labelText,
            defaultValue: widget.defaultValue.from,
            onChanged: (value) {
              _value.from = value;
              widget.onChanged(_value);
            },
          ),
        )),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: IncompleteDateWidget(
            labelText: '',
            defaultValue: widget.defaultValue.to,
            onChanged: (value) {
              _value.to = value;
              widget.onChanged(_value);
            },
          ),
        )),
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    _value = widget.defaultValue;
  }
}
