import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

class DropDownTextFieldGeneric<T> extends StatefulWidget {

  const DropDownTextFieldGeneric({
    super.key,
    required this.dropDownList,
    required this.labelText,
    required this.onChanged,
    required this.nameBuilder,
    required this.equator,
    this.initValue,
  });

  final T? initValue;
  final FutureOr<List<T>> dropDownList;
  final String labelText;
  final ValueChanged<T> onChanged;
  final String Function(T value) nameBuilder;
  final bool Function(T v1, T v2) equator;

  @override
  State<StatefulWidget> createState() {
    return _DropDownTextFieldState<T>();
  }

}

class _DropDownTextFieldState<T> extends State<DropDownTextFieldGeneric<T>> {

  late Future<List<DropDownValueModel>> dropDownList;
  late SingleValueDropDownController controller;

  @override
  void initState() {
    super.initState();
    dropDownList = getDropDownList();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: dropDownList,
        builder: (BuildContext context,
            AsyncSnapshot<List<DropDownValueModel>> snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return TextFormField(
              readOnly: true,
              decoration: InputDecoration(labelText: widget.labelText),
            );
          }
          DropDownValueModel? initD = (widget.initValue == null) ? null
           : snapshot.data!.firstWhereOrNull((DropDownValueModel entry)
           => widget.equator(entry.value, widget.initValue!));
          if (initD == null) {
            controller = SingleValueDropDownController();
          } else {
            controller = SingleValueDropDownController(data: initD);
          }
          return DropDownTextField(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            clearOption: true,
            enableSearch: true,
            dropDownItemCount: 6,
            onChanged: (value) {
              if (value == null) {
                widget.onChanged(value);
              } else {
                widget.onChanged(cast((value as DropDownValueModel).value));
              }
            },
            textFieldDecoration: InputDecoration(labelText: widget.labelText),
            dropDownList: snapshot.data!,
          );
        });
  }

  Future<List<DropDownValueModel>> getDropDownList() async {
    List<DropDownValueModel> dropDownList = [];
    for (T entry in await widget.dropDownList) {
      dropDownList.add(DropDownValueModel(value: entry, name: widget.nameBuilder(entry)));
    }
    return dropDownList;
  }

  T cast(dynamic value) => value as T;

}
