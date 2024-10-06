import 'package:flutter/material.dart';

class TappedTextCheckBox extends StatefulWidget {
  bool value;
  final String labelText;
  final ValueChanged<bool> onChanged;
  TappedTextCheckBox({
    super.key,
    required this.value,
    required this.labelText,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return _TappedTextCheckBoxState();
  }
}

class _TappedTextCheckBoxState extends State<TappedTextCheckBox> {

  @override
  void initState() {
    super.initState();
    isChecked = widget.value;
  }

  late bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: isChecked,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                isChecked = value!;
                widget.onChanged(isChecked);
              });
            }
        ),
        GestureDetector(
          onTap: (() {
            setState(() {
              isChecked = !isChecked;
              widget.onChanged(isChecked);
            });
          }),
          child: Text(
              widget.labelText,
          ),
        )
      ],
    );
  }

}