import 'package:digikam/search/bloc.dart';
import 'package:digikam/util/keyword_holder.dart';
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
import '../services/backend_service.dart';
import '../services/constant_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late String _author;
  StringDropDownValue? _orientation;
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
  late bool searchForVideos;

  @override
  void initState() {
    super.initState();
    remoteUrl = SettingsFactory().settings.url;
    _author = '';
    _camera = '';
    _canSearch = false;
    authors = _getAuthors();
    cameras = _getCameras();
    keywordHolder = getKeywords();
    _searchBloc = SearchBloc();
    searchForVideos = false;
  }

  @override
  void dispose() {
    super.dispose();
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
        child: BlocConsumer<SearchBloc, SearchState>(
          listener: (context, state) {
            if (state is SearchDataState) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageSlider(images: state.list)));
              _searchBloc.add(SearchInitializedEvent());
            } else if (state is SearchNoDataState) {
              SnackBar snackBar = SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.searchNoDataFound));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              _searchBloc.add(SearchInitializedEvent());
            } else if (state is SearchErrorState) {
              SnackBar snackBar = SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.messageError(state.msg)));
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
        ));
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
              labelText: AppLocalizations.of(context)!.searchKeywords,
              values: keywordHolder,
            ),
            DropDownTextFieldGeneric<String>(
              defaultValue: '',
              dropDownList: CreatorService.getAuthors(),
              labelText: AppLocalizations.of(context)!.searchCreator,
              onChanged: (value) {
                _author = value;
              },
              nameBuilder: (String value) {
                return value;
              },
              equator: (String v1, String v2) {
                return v1 == v2;
              },
              initValue: _author,
            ),
            DropDownTextFieldGeneric<String>(
              defaultValue: '',
              dropDownList: CameraService.getCameras(),
              labelText: AppLocalizations.of(context)!.searchCamera,
              onChanged: (value) {
                _camera = value;
              },
              nameBuilder: (String value) {
                return value;
              },
              equator: (String v1, String v2) {
                return v1 == v2;
              },
              initValue: _camera,
            ),
            DropDownTextFieldGeneric<StringDropDownValue>(
              defaultValue: const StringDropDownValue(name: '', value: ''),
              onChanged: (StringDropDownValue selected) {
                _orientation = selected;
              },
              nameBuilder: (StringDropDownValue entry) {
                return entry.name;
              },
              equator: (StringDropDownValue v1, StringDropDownValue v2) {
                return v1 == v2;
              },
              labelText: AppLocalizations.of(context)!.searchFormat,
              dropDownList: DropDownValueConstants.orientationValues(context),
              initValue: _orientation,
            ),
            RangeDateWidget(
              labelText: AppLocalizations.of(context)!.searchDate,
              defaultValue: _dateRange,
              onChanged: (RowRangeIncompleteDate value) {
                _dateRange = value;
              },
            ),
            RangeIntWithDropDownWidget(
              defaultValue: _rating,
              labelText: AppLocalizations.of(context)!.searchRating,
              dropDownList: constants.ratingValues,
              onChanged: (RowRangeInt value) {
                _rating = value;
              },
            ),
            RangeIntWithDropDownWidget(
              defaultValue: _iso,
              labelText: AppLocalizations.of(context)!.searchIso,
              dropDownList: constants.isoValues,
              onChanged: (RowRangeInt value) {
                _iso = value;
              },
            ),
            RangeDoubleWithDropDownWidget(
              defaultValue: _aperture,
              labelText: AppLocalizations.of(context)!.searchAperture,
              dropDownList: constants.apertureValues,
              onChanged: (RowRangeDouble value) {
                _aperture = value;
              },
            ),
            RangeIntWithDropDownWidget(
              defaultValue: _focalLength,
              labelText: AppLocalizations.of(context)!.searchFocalLength,
              dropDownList: constants.focalLengthValues,
              onChanged: (RowRangeInt value) {
                _focalLength = value;
              },
            ),
            RangeDoubleWithDropDownWidget(
              defaultValue: _exposureTime,
              labelText: AppLocalizations.of(context)!.searchExposureTime,
              dropDownList: constants.exposureValues,
              onChanged: (RowRangeDouble value) {
                _exposureTime = value;
              },
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: ElevatedButton(
                    child:
                        Text(AppLocalizations.of(context)!.searchCommandSearch),
                    onPressed: () {
                      if (_checkCanSearch()) {
                        context.read<SearchBloc>().add(SearchStartedEvent(
                            searchForVideos: false,
                            keywords: _keywords,
                            author: _author,
                            camera: _camera,
                            orientation: (_orientation == null)
                                ? ''
                                : _orientation!.value,
                            date: _dateRange,
                            rating: _rating,
                            iso: _iso,
                            exposureTime: _exposureTime,
                            aperture: _aperture,
                            focalLength: _focalLength));
                      }
                    },
                  ),
                )),
                SizedBox(
                  height: 36,
                  width: 36,
    //              padding: const EdgeInsets.only(right: 4.0),
                  child: Ink(
                      decoration: ShapeDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                      ),
                      child: IconButton(
                        icon: (searchForVideos)
                            ? const Icon(Icons.switch_video_sharp)
                            : const Icon(Icons.photo),
                        tooltip: (searchForVideos)
                            ? 'Search for Videos'
                            : 'Search for Photos',
                        onPressed: () {
                          setState(() {
                            searchForVideos = !searchForVideos;
                          });
                        },
                      )),
                )
              ],
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
        (_orientation != null && _orientation!.name.isNotEmpty) ||
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
    for (String entry in await CreatorService.getAuthors()) {
      creators.add(DropDownValueModel(name: entry, value: entry));
    }
    return creators;
  }

  Future<List<DropDownValueModel>> _getCameras() async {
    List<DropDownValueModel> result = [];
    for (String camera in await CameraService.getCameras()) {
      result.add(DropDownValueModel(name: camera, value: camera));
    }
    return result;
  }

  Future<KeywordHolder> getKeywords() async {
    List<Keyword> keywords = await KeywordService.getKeywords();
    KeywordHolder kh = KeywordHolder();
    for (Keyword k in keywords) {
      kh.add(k);
    }
    return kh;
  }
}
