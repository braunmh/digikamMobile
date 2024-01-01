import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

/// Called to retrieve the suggestions for [search].
typedef DropDownSuggestionsCallback<T> = Future<List<T>> Function(String search);

/// Builds the value which is displayed in the DropDownList
typedef DropDownNameBuilder<T> = String Function(T value); 

class DropDownTextFieldDynamic extends StatelessWidget {
   const DropDownTextFieldDynamic({
    super.key,
    required this.dropDownList,
    required this.labelText,
    required this.onChanged,
     this.controller,
  });

  final Future<List<DropDownValueModel>> dropDownList;
  final String labelText;
  final ValueChanged<String> onChanged;
  final SingleValueDropDownController? controller;

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
              decoration: InputDecoration(labelText: labelText),
            );
          }
          return DropDownTextField(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            clearOption: true,
            enableSearch: true,
            dropDownItemCount: 6,
            onChanged: (value) {
              if (value == null || value is String) {
                onChanged(value);
              } else {
                onChanged((value as DropDownValueModel).value);
              }
            },
            textFieldDecoration: InputDecoration(labelText: labelText),
            dropDownList: snapshot.data!,
          );
        });
  }
}

class DropDownTextFieldDynamicG<T> extends StatefulWidget {

  const DropDownTextFieldDynamicG({
    super.key,
    required this.dropDownList,
    required this.labelText,
    required this.onChanged,
    required this.nameBuilder,
    required this.equator,
    required this.initValue,
  });

  final T initValue;
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

class _DropDownTextFieldState<T> extends State<DropDownTextFieldDynamicG<T>> {

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
          DropDownValueModel? initD = snapshot.data!.firstWhereOrNull((DropDownValueModel entry)
           => widget.equator(entry.value, widget.initValue));
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
