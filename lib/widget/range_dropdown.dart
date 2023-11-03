import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

import '../util/range.dart';

class RangeIntWithDropDownWidget extends StatefulWidget {
  @override
  RangeIntWithDropDownWidgetState createState() => RangeIntWithDropDownWidgetState();

  final ValueChanged<RowRangeInt> onChanged;
  final RowRangeInt defaultValue;
  final String labelText;
  final List<DropDownValueModel> dropDownList;

  const RangeIntWithDropDownWidget({
    super.key,
    required this.defaultValue,
    required this.onChanged,
    required this.labelText,
    required this.dropDownList,
    });
}

class RangeIntWithDropDownWidgetState extends State<RangeIntWithDropDownWidget> {

  final RowRangeInt parseValue = RowRangeInt();
  late SingleValueDropDownController _cntFrom;
  late SingleValueDropDownController _cntTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: DropDownTextField(
              controller: _cntFrom,
              textFieldDecoration: InputDecoration(
                  labelText: widget.labelText),
              clearOption: true,
              enableSearch: false,
              dropDownItemCount: 6,
              onChanged: (value) {
                parseValue.from = widget.defaultValue.parse(_processInput(value));
                widget.onChanged(parseValue);
              },
              dropDownList: widget.dropDownList,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: DropDownTextField(
              controller: _cntTo,
              textFieldDecoration: const InputDecoration(
                  labelText: ""),
              clearOption: true,
              enableSearch: false,
              dropDownItemCount: 6,
              onChanged: (value) {
                parseValue.to = widget.defaultValue.parse(_processInput(value));
                widget.onChanged(parseValue);
              },
              dropDownList: widget.dropDownList,
            ),
          ),
        )
      ],

    );  }

  @override
  void initState() {
    super.initState();
    _cntFrom  = SingleValueDropDownController();
    _cntTo = SingleValueDropDownController();
  }

  @override
  void dispose() {
    super.dispose();
    _cntFrom.dispose();
    _cntTo.dispose();
  }
  
  String _processInput(dynamic value) {
    if (value == null || value is String) return '0';
    try {
      return (value as DropDownValueModel).value;
    } catch(e) {
      return '';
    }
  }
}
class RangeDoubleWithDropDownWidget extends StatefulWidget {
  @override
  RangeDoubleWithDropDownWidgetState createState() => RangeDoubleWithDropDownWidgetState();

  final ValueChanged<RowRangeDouble> onChanged;
  final RowRangeDouble defaultValue;
  final String labelText;
  final List<DropDownValueModel> dropDownList;

  const RangeDoubleWithDropDownWidget({
    super.key,
    required this.defaultValue,
    required this.onChanged,
    required this.labelText,
    required this.dropDownList,
  });
}

class RangeDoubleWithDropDownWidgetState extends State<RangeDoubleWithDropDownWidget> {

  final RowRangeDouble parseValue = RowRangeDouble();
  late SingleValueDropDownController _cntFrom;
  late SingleValueDropDownController _cntTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: DropDownTextField(
              controller: _cntFrom,
              textFieldDecoration: InputDecoration(
                  labelText: widget.labelText),
              clearOption: true,
              enableSearch: false,
              dropDownItemCount: 6,
              onChanged: (value) {
                parseValue.from = widget.defaultValue.parse(_processInput(value));
                widget.onChanged(parseValue);
              },
              dropDownList: widget.dropDownList,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: DropDownTextField(
              controller: _cntTo,
              textFieldDecoration: const InputDecoration(
                  labelText: ""),
              clearOption: true,
              enableSearch: false,
              dropDownItemCount: 6,
              onChanged: (value) {
                parseValue.to = widget.defaultValue.parse(_processInput(value));
                widget.onChanged(parseValue);
              },
              dropDownList: widget.dropDownList,
            ),
          ),
        )
      ],

    );  }

  @override
  void initState() {
    super.initState();
    _cntFrom  = SingleValueDropDownController();
    _cntTo = SingleValueDropDownController();
  }

  @override
  void dispose() {
    super.dispose();
    _cntFrom.dispose();
    _cntTo.dispose();
  }

  String _processInput(dynamic value) {
    if (value == null || value is String) return '0';
    try {
      return (value as DropDownValueModel).value;
    } catch(e) {
      return '';
    }
  }
}
