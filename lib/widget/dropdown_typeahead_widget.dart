import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_typeahead/src/common/base/types.dart';

class TypeAheadWidget<T> extends StatefulWidget {

  final String labelText;
  final SuggestionsCallback<T> suggestionsCallback;
  final ValueSetter<T> onSuggestionSelected;
  final String hintText;
  final ItemBuilder<T> itemBuilder;
  final TextEditingController controller;

  const TypeAheadWidget({
    super.key,
    this.hintText = '',
    required this.labelText,
    required this.suggestionsCallback,
    required this.onSuggestionSelected,
    required this.itemBuilder,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() {
    return _TypeAheadState<T>();
  }
}

class _TypeAheadState<T> extends State<TypeAheadWidget<T>> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      builder: (context, controller, focusNode) => TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        ),
      ),
        controller: widget.controller,
        suggestionsCallback: (pattern) => widget.suggestionsCallback(pattern),
        itemBuilder: (context, T item) => widget.itemBuilder(context, item),
        itemSeparatorBuilder: (context, index) => const Divider(),
        onSelected: (T suggestion) => widget.onSuggestionSelected(suggestion),
    );
  }

}