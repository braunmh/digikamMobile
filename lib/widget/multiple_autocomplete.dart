import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:multiple_search_selection/createable/create_options.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';

class MultipleAutoComplete<T> extends StatefulWidget {
  final List<T> result;
  final String labelText;
  final FutureOr<List<T>> dropDownList;
  final String Function(T item) nameBuilder;
  final String Function(T item) fieldToCheck;
  final List<T> initialValues;

  MultipleAutoComplete({
    super.key,
    required this.result,
    required this.labelText,
    required this.dropDownList,
    required this.nameBuilder,
    required this.fieldToCheck,
    initialValues,
  }) :
      initialValues = initialValues ?? List.empty()
  ;
  @override
  State<StatefulWidget> createState() {
    return _MuMultipleAutoCompleteState<T>();
  }
}

class _MuMultipleAutoCompleteState<T> extends State<MultipleAutoComplete<T>> {
  
  late MultipleSearchController controller;
  
  @override
  void initState() {
    super.initState();
    controller = MultipleSearchController();
    widget.result.addAll(widget.initialValues);
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDropDownList(),
        builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return TextFormField(
              readOnly: true,
              decoration: InputDecoration(labelText: widget.labelText),
            );
          }
          return buildSearchWidget(snapshot.data!);

    });
  }

  Future<List<T>> getDropDownList() async {
    return widget.dropDownList;
  }

  Column buildSearchWidget(List<T> dropDownList) {
    return Column(
    children: [
      MultipleSearchSelection<T>.creatable(
        initialPickedItems: widget.initialValues,
        itemsVisibility: ShowedItemsVisibility.onType,
        searchField: TextField(
          decoration: InputDecoration(
            hintText: widget.labelText,
          ),
        ),
        createOptions: CreateOptions(
          create: (String text) {
            return dropDownList.firstWhere((t) => widget.nameBuilder(t) == text);
          },
          validator: (T item) {
            return widget.nameBuilder(item).length > 1;
          },
          onDuplicate: (T item) {
            log('Duplicate item $item');
          },
          allowDuplicates: false,
          onCreated: (item) => log('T ${widget.nameBuilder(item)} created'),
          createBuilder: (text) => Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text('Create "$text"'),
            ),
          ),
          pickCreated: true,
        ),
        controller: controller,
        onItemAdded: (T item) {
          controller.getAllItems();
          controller.getPickedItems();
          widget.result.add(item);
        },
        onItemRemoved: (T item) {
          widget.result.remove(item);
        },
        clearSearchFieldOnSelect: true,
        items: dropDownList, // List<T>
        fieldToCheck: (T item) {
          return widget.fieldToCheck(item);
        },
        itemBuilder: (T item, int index, bool isPicked) {
          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3.0,
                  horizontal: 3,
                ),
                child: Text(
                    widget.nameBuilder(item),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
          );
        },
        pickedItemBuilder: (T item) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                widget.nameBuilder(item),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        },
        sortShowedItems: false,
        sortPickedItems: false,
        caseSensitiveSearch: false,
        fuzzySearch: FuzzySearch.none,
        showSelectAllButton: false,
        showClearAllButton: false,
        maximumShowItemsHeight: 200,
      ),
    ],
  );
  }
}
