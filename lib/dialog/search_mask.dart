import 'package:built_collection/built_collection.dart';
import 'package:digikam/search/bloc.dart';
import 'package:digikam/widget/range_date.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings.dart';
import '../util/range.dart';
import '../widget/dropdown_textfield_dynamic.dart';
import 'image_slider.dart';
import '../widget/range_dropdown.dart';
import '../widget/keyword_widget.dart';
import 'package:openapi/openapi.dart';
import '../constants.dart' as constants;

class SearchMask extends StatefulWidget {
  const SearchMask({
    super.key,
    required this.appBarHeight,
  });

  final double appBarHeight;

  @override
  SearchMaskState createState() {
    return SearchMaskState();
  }
}

class SearchMaskState extends State<SearchMask> {
  final _formKey = GlobalKey<FormState>();

  late String remoteUrl;

//  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SingleValueDropDownController _cntAuthor;
  late String _author;
  late String _orientation;
  late bool _canSearch;
  late String _camera;
  RowRangeInt _rating = RowRangeInt();
  RowRangeInt _iso = RowRangeInt();
  RowRangeInt _focalLength = RowRangeInt();
  RowRangeDouble _aperture = RowRangeDouble();
  RowRangeDouble _exposureTime = RowRangeDouble(inverse: true);
  RowRangeIncompleteDate _dateRange = RowRangeIncompleteDate(onlyDate: true);
  final List<Keyword> _keywords = [];

  late Future<List<DropDownValueModel>> authors;
  late Future<List<DropDownValueModel>> cameras;
  late Future<KeywordHolder> keywordHolder;

  late SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    remoteUrl = SettingsFactory().settings.url;
    _author = '';
    _orientation = '';
    _camera = '';
    _canSearch = false;
    _cntAuthor = SingleValueDropDownController();
    authors = _getAuthors();
    cameras = _getCameras();
    keywordHolder = getKeywords();
    _searchBloc = SearchBloc();
  }

  @override
  void dispose() {
    super.dispose();
    _cntAuthor.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (context) => _searchBloc,
      child: BlocConsumer<SearchBloc, SearchState> (
        listener: (context, state) {
          if (state is SearchDataState) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
              ImageSlider(images: state.list)
              )
            );
            _searchBloc.add(SearchInitializedEvent());
          } else if (state is SearchNoDataState) {
            SnackBar snackBar = const SnackBar(content: Text('Es wurden keine Bilder gefunden, die den Suchkriterien entsprechen'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _searchBloc.add(SearchInitializedEvent());
          } else if (state is SearchErrorState) {
            SnackBar snackBar = SnackBar(content: Text('Es ist ein Fehler aufgetreten: ${state.msg}'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _searchBloc.add(SearchInitializedEvent());
          }
        },
        builder: (context, state) {
          return state is SearchSearchState
           ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: CircularProgressIndicator(),
          )
          : buildSearchMask(context);
        },
      )
    );
  }

  Container buildSearchMask(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            KeywordWidget(
              defaultValues: _keywords,
              result: _keywords,
              labelText: "Tags",
              values: keywordHolder,
            ),
            DropDownTextFieldDynamic(
              dropDownList: authors,
              labelText: "Urheber",
              onChanged: (value) {
                _author = value;
              },
            ),
            DropDownTextFieldDynamic(
              dropDownList: cameras,
              labelText: "Kamera",
              onChanged: (value) {
                _camera = value;
              },
            ),
            DropDownTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              clearOption: true,
              enableSearch: false,
              dropDownItemCount: 6,
              onChanged: (value) {
                if (value == null || value is String) {
                  _orientation = '';
                } else {
                  _orientation = (value as DropDownValueModel).value;
                }
              },
              textFieldDecoration: const InputDecoration(labelText: 'Format'),
              dropDownList: constants.orientationValues,
            ),
            RangeDateWidget(
              labelText: 'Datum',
              defaultValue: _dateRange,
              onChanged: (RowRangeIncompleteDate value) {
                _dateRange = value;
              },
            ),
            RangeIntWithDropDownWidget(
              defaultValue: _rating,
              labelText: "Bewertung",
              dropDownList: constants.ratingValues,
              onChanged: (RowRangeInt value) {
                _rating = value;
              },
            ),
            RangeIntWithDropDownWidget(
              defaultValue: _iso,
              labelText: "ISO",
              dropDownList: constants.isoValues,
              onChanged: (RowRangeInt value) {
                _iso = value;
              },
            ),
            RangeDoubleWithDropDownWidget(
              defaultValue: _aperture,
              labelText: "Blende",
              dropDownList: constants.apertureValues,
              onChanged: (RowRangeDouble value) {
                _aperture = value;
              },
            ),
            RangeIntWithDropDownWidget(
              defaultValue: _focalLength,
              labelText: "Brennweite",
              dropDownList: constants.focalLengthValues,
              onChanged: (RowRangeInt value) {
                _focalLength = value;
              },
            ),
            RangeDoubleWithDropDownWidget(
              defaultValue: _exposureTime,
              labelText: "Belichtungszeit",
              dropDownList: constants.exposureValues,
              onChanged: (RowRangeDouble value) {
                _exposureTime = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                child: const Text('Suche'),
                onPressed: () {
                  if (_checkCanSearch()) {
                    context.read<SearchBloc>().add(SearchStartedEvent(
                        keywords: _keywords,
                        author: _author,
                        camera: _camera,
                        orientation: _orientation,
                        date: _dateRange,
                        rating: _rating,
                        iso: _iso,
                        exposureTime: _exposureTime,
                        aperture: _aperture,
                        focalLength: _focalLength));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _checkCanSearch() {
    _canSearch = _author.isNotEmpty ||
        _keywords.isNotEmpty ||
        _camera.isNotEmpty ||
        _orientation.isNotEmpty ||
        _dateRange.isNotEmpty() ||
        _rating.isNotEmpty() ||
        _iso.isNotEmpty() ||
        _aperture.isNotEmpty() ||
        _focalLength.isNotEmpty() ||
        _exposureTime.isNotEmpty();
    return _canSearch;
  }

  Future<List<DropDownValueModel>> _getAuthors() async {
    List<DropDownValueModel> creators = [];
    CreatorApi api = Openapi(basePathOverride: remoteUrl).getCreatorApi();

    final response = await api.findCreatorsByName(name: '');
    if (response.statusCode == 200) {
      for (Creator creator in response.data!) {
        String name = creator.name;
        creators.add(DropDownValueModel(name: name, value: name));
      }
      return Future(() => creators);
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  Future<List<DropDownValueModel>> _getCameras() async {
    List<DropDownValueModel> result = [];
    CameraApi api = Openapi(basePathOverride: remoteUrl).getCameraApi();
    final response = await api.findCamerasByMakerAndModel(makeAndModel: '');
    if (response.statusCode == 200) {
      for (Camera camera in response.data!) {
        String name = camera.name;
        result.add(DropDownValueModel(name: name, value: name));
      }
      return Future(() => result);
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  Future<KeywordHolder> getKeywords() async {
    KeywordsApi api = Openapi(basePathOverride: remoteUrl).getKeywordsApi();
    final response = await api.findKeywordsByName(name: '');
    if (response.statusCode == 200) {
      KeywordHolder kh = KeywordHolder();
      for (Keyword k in response.data!) {
        kh.add(k);
      }
      return kh;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }
}

class KeywordHolder {
  final List<Keyword> _keywords = [];
  final List<String> _keywordValues = [];

  void add(Keyword value) {
    _keywords.add(value);
    _keywordValues.add(value.name);
  }

  BuiltList<int>? getParameter(List<String> params) {
    if (params.isNotEmpty) {
      return null;
    }
    List<int> result = [];
    for (String s in params) {
      Keyword k = getByName(s);
      result.add(k.id);
        }
    if (result.isEmpty) {
      return null;
    }
    return result.build();
  }

  Keyword getByName(String value) {
    for (Keyword k in _keywords) {
      if (value.toLowerCase() == k.name.toLowerCase()) {
        return k;
      }
    }
    return Keyword();
  }

  List<String> get keywordValues {
    return _keywordValues;
  }
}


