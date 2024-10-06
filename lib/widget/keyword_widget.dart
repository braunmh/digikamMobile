import 'package:digikam/util/keyword_holder.dart';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:textfield_tags/textfield_tags.dart';

class KeywordWidget extends StatefulWidget {
  final List<Keyword> result;
  final String labelText;
  final Future<KeywordHolder> values;
  final List<Keyword> defaultValues;

  const KeywordWidget({
    super.key,
    required this.result,
    required this.labelText,
    required this.values,
    defaultValues,
  }) :
    defaultValues = defaultValues ?? List
  ;

  @override
  KeywordWidgetState createState() {
    return KeywordWidgetState();
  }
}

class KeywordWidgetState extends State<KeywordWidget> {

  final Color _color = const Color.fromARGB(207, 33, 150, 243);
  late double _distanceToField;
  late TextfieldTagsController<String> _controller;

  //FocusNode _tagsNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder();
  }

  FutureBuilder<KeywordHolder> buildFutureBuilder() {
    return FutureBuilder(
        future: widget.values,
        builder: (BuildContext context, AsyncSnapshot<KeywordHolder> snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else if (!snapshot.hasData) {
            return TextFormField(
                readOnly: true,
                decoration: InputDecoration(labelText: widget.labelText));
          }
          KeywordHolder data = snapshot.data!;
          return Autocomplete<String>(
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topCenter,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400, minWidth: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dynamic option = options.elementAt(index);
                        return TextButton(
                          onPressed: () {
                            onSelected(option);
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                '#$option',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: _color,),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return data.keywordValues.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selectedTag) {
              _controller.addTag(selectedTag);
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextFieldTags<String>(
                textEditingController: textEditingController,
                focusNode: focusNode,
                textfieldTagsController: _controller,
                initialTags: widget.defaultValues.map((e) => e.name).toList(),
                textSeparators: const [','],
                letterCase: LetterCase.normal,
                validator: (tag) {
                  if (tag is String) {
                    String text = tag;
                    Keyword k = data.getByName(text);
                    widget.result.add(k);
                    if (_controller.getTags!.contains(text)) {
                      return 'you already entered that';
                    }
                  }
                  return null;
                },
                inputFieldBuilder: (context, inputFieldValues) {
                  return TextField(
                    onTap: () {
                      _controller.getFocusNode?.requestFocus();
                    },
                    controller: inputFieldValues.textEditingController,
                    focusNode: inputFieldValues.focusNode,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 74, 137, 92),
                          width: 3.0,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 74, 137, 92),
                          width: 3.0,
                        ),
                      ),
                      helperText: 'Enter language...',
                      helperStyle: const TextStyle(
                        color: Color.fromARGB(255, 74, 137, 92),
                      ),
                      hintText: inputFieldValues.tags.isNotEmpty
                          ? ''
                          : "Enter tag...",
                      errorText: inputFieldValues.error,
                      prefixIconConstraints:
                      BoxConstraints(maxWidth: _distanceToField * 0.8),
                      prefixIcon: inputFieldValues.tags.isEmpty
                          ? SingleChildScrollView(
                        controller: inputFieldValues.tagScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children:
                            inputFieldValues.tags.map((String tag) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color.fromARGB(255, 74, 137, 92),
                                ),
                                margin: const EdgeInsets.only(right: 10.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      child: Text(
                                        '#$tag',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      onTap: () {
                                        //print("$tag selected");
                                      },
                                    ),
                                    const SizedBox(width: 4.0),
                                    InkWell(
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 14.0,
                                        color: Color.fromARGB(
                                            255, 233, 233, 233),
                                      ),
                                      onTap: () {
                                        inputFieldValues.onTagRemoved(tag);
                                      },
                                    )
                                  ],
                                ),
                              );
                            }).toList()),
                      )
                          : null,
                    ),
                    onChanged: inputFieldValues.onTagChanged,
                    onSubmitted: inputFieldValues.onTagSubmitted,
                  );
                },
              );
            },
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }
}
