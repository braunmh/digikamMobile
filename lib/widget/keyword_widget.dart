import 'package:digikam/util/keyword_holder.dart';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:collection/collection.dart';

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
  late TextfieldTagsController _controller;

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
              _controller.addTag = selectedTag;
            },
            fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
              return TextFieldTags(
                textEditingController: ttec,
                focusNode: tfn,
                textfieldTagsController: _controller,
                initialTags: widget.defaultValues.map((e) => e.name).toList(),
                textSeparators: const [','],
                letterCase: LetterCase.normal,
                validator: (String tag) {
                  if (_controller.getTags!.contains(tag)) {
                    return 'you already entered that';
                  }
                  Keyword k = data.getByName(tag);
                  widget.result.add(k);
                                  return null;
                },
                inputfieldBuilder:
                    (context, tec, fn, error, onChanged, onSubmitted) {
                  return ((context, sc, tags, onTagDelete) {
                    return TextField(
                      controller: tec,
                      focusNode: fn,
                      decoration: InputDecoration(
                        hintText: _controller.hasTags ? '' : widget.labelText,
                        errorText: error,
                        prefixIconConstraints:
                            BoxConstraints(maxWidth: _distanceToField * 0.74),
                        prefixIcon: tags.isNotEmpty
                            ? SingleChildScrollView(
                                controller: sc,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children: tags.map((String tag) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: _color,
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
                                            tag,
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: Colors.white,
                                          ),
                                          onTap: () {
                                            onTagDelete(tag);
                                            Keyword? k = widget.result.firstWhereOrNull((element) => tag.toLowerCase() == element.name.toLowerCase());
                                            if (k != null) {
                                              widget.result.remove(k);
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                              )
                            : null,
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    );
                  });
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
