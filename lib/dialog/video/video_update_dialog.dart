import 'package:digikam/services/backend_service.dart';
import 'package:digikam/util/keyword_holder.dart';
import 'package:digikam/widget/dropdown_textfield_dynamic.dart';
import 'package:digikam/widget/keyword_widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_local;
import 'package:openapi/openapi.dart' as api;
import '../../l10n/app_localizations.dart';
import '../../services/constant_service.dart';


/// Dialog for change Information (not EXIF-Data) of an Image
class VideoUpdateDialog extends StatefulWidget {
  final int videoId;

  const VideoUpdateDialog({
    super.key,
    required this.videoId,
  });

  @override
  State<StatefulWidget> createState() {
    return _VideoUpdateDialogState();
  }
}

class _VideoUpdateDialogState extends State<VideoUpdateDialog> {
  late int rating;
  late String title;
  late String description;
  late String creator;
  late Future<KeywordHolder> keywordHolder;
  late List<api.Keyword> keywords;
  late Future<List<DropDownValueModel>> creators;

  @override
  void initState() {
    super.initState();
    date_local.initializeDateFormatting('DE_de', null);
    keywordHolder = getKeywords();
    creators = getAuthors();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(4.0),
      child: FutureBuilder<api.Video>(
          future: VideoService.getVideoInformation(widget.videoId),
          builder: (BuildContext context, AsyncSnapshot<api.Video> snapshot) {
            if (snapshot.hasError) {
              return Text(AppLocalizations.of(context)!
                  .messageError('${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              api.Video video = snapshot.data!;
              rating = video.rating ?? 0;
              IntDropDownValue ratingInit = DropDownValueConstants.ratingValues.firstWhere(
                      (element) => element.value == rating,
                  orElse: () => DropDownValueConstants.ratingValues[0]);
              keywords = (video.keywords == null) ? [] : video.keywords!.toList();
              title = video.title ?? '';
              description = video.description ?? '';
              creator = video.creator ?? '';
              return Form(
                child: ListView(
                children: [
                  textFormField(
                      'Datum',
                      (video.creationDate == null)
                          ? ''
                          : DateFormat.yMd('DE_de')
                              .add_Hms()
                              .format(video.creationDate!)),
                  textFormField(AppLocalizations.of(context)!.searchId, '${video.id}'),
                  textFormField(AppLocalizations.of(context)!.searchName, video.name),
                  textFormEditField(
                      labelText:  AppLocalizations.of(context)!.searchTitle,
                      value:  video.title ?? '',
                      onChanged: (String value) {
                        title = value;
                    }
                  ),
                  textFormEditField(
                      labelText: AppLocalizations.of(context)!.searchDescription,
                      value: video.description ?? '',
                      onChanged: (String value) {description = value;}),
                  Container(
                    child: KeywordWidget(
                      defaultValues: keywords,
                      result: keywords,
                      labelText: AppLocalizations.of(context)!.searchKeywords,
                      values: keywordHolder,
                    ),
                  ),
                  DropDownTextFieldGeneric<IntDropDownValue>(
                    defaultValue: const IntDropDownValue(name: '', value: 0),
                    dropDownList: DropDownValueConstants.ratingValues,
                    onChanged: (IntDropDownValue selected) {
                      rating = selected.value;
                    },
                    labelText: AppLocalizations.of(context)!.searchRating,
                    nameBuilder: (IntDropDownValue value) {
                        return value.name;
                    },
                    equator: (IntDropDownValue v1, IntDropDownValue v2) {
                      return v1.value == v2.value;
                    },
                    initValue: ratingInit,
                  ),
                  DropDownTextFieldGeneric<String>(
                    defaultValue: '',
                    dropDownList: CreatorService.getAuthors(),
                    labelText: AppLocalizations.of(context)!.searchCreator,
                    onChanged: (String selected) {
                      creator = selected;
                    },
                    nameBuilder: (String value) {
                      return value;
                    },
                    equator: (String v1, String v2) {
                      return v1 == v2;
                    },
                    initValue: creator,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ImageService.update(
                            imageId: widget.videoId,
                            rating: rating,
                            creator: creator,
                            title: title,
                            description: description,
                            keywords: keywords
                          );
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.commonSave),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.commonQuit),
                      ),
                    ],
                  ),
                ],
              ));
            }
          }),
    ));
  }

  TextFormField textFormField(String labelText, String? value) {
    return TextFormField(
      decoration: InputDecoration(labelText: labelText),
      readOnly: true,
      initialValue: value,
      maxLines: null,
    );
  }

  TextFormField textFormEditField({required String labelText, required String value, required ValueSetter<String> onChanged}) {
    return TextFormField(
      decoration: InputDecoration(labelText: labelText),
      readOnly: false,
      initialValue: value,
      maxLines: 5,
      onChanged: onChanged,
      minLines: 1,
    );
  }

  int parseInt(String value) {
    try {
      return num.parse(value).toInt();
    } catch (e) {
      return 0;
    }
  }

  Future<KeywordHolder> getKeywords() async {
    List<api.Keyword> keywords = await KeywordService.getKeywords();
    KeywordHolder kh = KeywordHolder();
    for (api.Keyword k in keywords) {
      kh.add(k);
    }
    return kh;
  }

  Future<List<DropDownValueModel>> getAuthors() async {
    List<DropDownValueModel> creators = [];
    for (String entry in await CreatorService.getAuthors()) {
      creators.add(DropDownValueModel(name: entry, value: entry));
    }
    return creators;
  }
}
