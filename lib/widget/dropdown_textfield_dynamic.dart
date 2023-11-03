import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

class DropDownTextFieldDynamic extends StatelessWidget {
  const DropDownTextFieldDynamic({
    super.key,
    required this.dropDownList,
    required this.labelText,
    required this.onChanged,
  });

  final Future<List<DropDownValueModel>> dropDownList;
  final String labelText;
  final ValueChanged<String> onChanged;

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
