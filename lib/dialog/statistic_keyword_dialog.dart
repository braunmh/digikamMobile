import 'package:digikam/statistic/keyword_bloc.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:openapi/openapi.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget/incomplete_date.dart';
import '../services/backend_service.dart';
import '../widget/dropdown_typeahead_widget.dart';

class StatisticKeywordDialog extends StatefulWidget {
  const StatisticKeywordDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StatisticKeywordState();
  }
}

class _StatisticKeywordState extends State<StatisticKeywordDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController typeAheadController;
  final yearKey = GlobalKey<FormFieldState>();

  late String yearIn;
  late String keywordIn;

  late int year;
  late int keywordId;

  late Future<List<DropDownValueModel>> keywords;
  late KeywordStatisticBloc bloc;
  late TextEditingController yearController;
  late FocusNode yearFocus;

  @override
  void initState() {
    super.initState();
    keywordIn = "";
    year = 0;
    keywordId = 0;
    bloc = KeywordStatisticBloc();
    keywords = getKeywords();
    yearController = TextEditingController();
    typeAheadController = TextEditingController();
    yearController.text = "";
    yearFocus = FocusNode();
    yearFocus.addListener(() {
      if (!yearFocus.hasFocus) {
        yearKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    yearController.dispose();
    yearFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<StatisticKeyword> result = [];

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.statisticKeywordTitle),
        ),
        body: Container(
            padding: const EdgeInsets.all(4.0),
            child: BlocProvider<KeywordStatisticBloc>(
                create: (context) => bloc,
                child:
                    BlocConsumer<KeywordStatisticBloc, KeywordStatisticState>(
                        listener: (context, state) {
                  if (state is KeywordStatisticDataState) {
                    result = state.list;
                    bloc.add(KeywordStatisticInitializedEvent());
                  } else if (state is KeywordStatisticNoDataState) {
                    result = [];
                    SnackBar snackBar = SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.messageNoDataFound));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (state is KeywordStatisticErrorState) {
                    result = [];
                    SnackBar snackBar = SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .messageError(state.msg)));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }, builder: (context, state) {
                  if (state is KeywordStatisticStartedEvent) {
                    return processingIndicator();
                  }
                  return Form(
                    key: formKey,
                    child: ListView(
                      children: <Widget>[
                        TypeAheadWidget(
                          suggestionsCallback: (pattern) =>
                              getKeywordSuggestions(pattern),
                          itemBuilder: (context, Keyword item) {
                            return Text(item.name);
                          },
                          controller: typeAheadController,
                          onSuggestionSelected: (Keyword suggestion) {
                            typeAheadController.text = suggestion.name;
                            keywordId = suggestion.id;
                          },
                          labelText: AppLocalizations.of(context)!
                              .statisticKeywordKeyword,
                          hintText: AppLocalizations.of(context)!
                              .statisticKeywordHintKeyword,
                        ),
//                        buildKeywordDropDown(context),
                        TextFormField(
                          key: yearKey,
                          focusNode: yearFocus,
                          controller: yearController,
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .statisticKeywordYear),
                          onChanged: (String value) {
                            yearIn = value;
                          },
                          validator: (String? value) {
                            if (value != null && value.isNotEmpty) {
                              try {
                                year = IncompleteDateUtil.parseYear(value);
                                yearController.text = year.toString();
                                if (year > DateTime.now().year) {
                                  year = 0;
                                  return AppLocalizations.of(context)!
                                      .statisticKeywordValidationNoFuture;
                                }
                              } catch (e) {
                                return AppLocalizations.of(context)!
                                    .statisticKeywordValidationYear;
                              }
                            }
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (isValid()) {
                                  context.read<KeywordStatisticBloc>().add(
                                      KeywordStatisticStartedEvent(
                                          keywordId: keywordId, year: year));
                                } else {
                                  SnackBar snackBar = SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .statisticKeywordValidationAll));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .statisticKeywordGenerate),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.commonClose),
                            ),
                          ],
                        ),
                        displayResult(context, result),
                      ],
                      // searchMask
                      // resultList
                    ),
                  );
                }))));
  }

  Widget displayResult(BuildContext context, List<StatisticKeyword> result) {
    if (result.isEmpty) {
      return Text(AppLocalizations.of(context)!.messageNoDataYet);
    } else {
      return DataTable(columns: <DataColumn>[
        DataColumn(
            label: Text(AppLocalizations.of(context)!.statisticKeywordKeyword)),
        DataColumn(
            label: Text(AppLocalizations.of(context)!.statisticKeywordCount)),
      ], rows: getRows(result));
    }
  }

  bool isValid() {
    return year > 0 && keywordId > 0;
  }

  List<DataRow> getRows(List<StatisticKeyword> result) {
    return result
        .map((entry) => DataRow(cells: [
              DataCell(Text(entry.name)),
              DataCell(Text(entry.count.toString())),
            ]))
        .toList();
  }

  Widget processingIndicator() {
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: CircularProgressIndicator());
  }

  Widget buildKeywordDropDown(BuildContext context) {
    return TypeAheadField<Keyword>(
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.statisticKeywordKeyword,
            hintText: AppLocalizations.of(context)!.statisticKeywordHintKeyword,
          ),
          controller: typeAheadController,
        ),
        suggestionsCallback: (pattern) => getKeywordSuggestions(pattern),
        itemBuilder: (context, Keyword item) {
          return Text(item.name);
        },
        itemSeparatorBuilder: (context, index) => const Divider(),
        onSuggestionSelected: (Keyword suggestion) {
          typeAheadController.text = suggestion.name;
          keywordId = suggestion.id;
        });
  }

  Future<List<DropDownValueModel>> getKeywords() async {
    List<DropDownValueModel> result = [];
    for (Keyword k in await KeywordService.getKeywords()) {
      result.add(DropDownValueModel(name: k.name, value: k.id.toString()));
    }
    return result;
  }

  Future<List<Keyword>> getKeywordSuggestions(String pattern) async {
    List<Keyword> keywords = await KeywordService.getKeywords();

    if (pattern.isEmpty) {
      return keywords;
    }
    pattern = pattern.toLowerCase();
    return keywords
        .where((k) => k.name.toLowerCase().contains(pattern))
        .toList();
  }
}
