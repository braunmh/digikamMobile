import 'package:digikam/services/backend_service.dart';
import 'package:digikam/util/keyword_holder.dart';
import 'package:digikam/widget/dropdown_textfield_dynamic.dart';
import 'package:digikam/widget/keyword_widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_local;
import 'package:openapi/openapi.dart' as api;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants.dart' as constants;


/// Dialog for change Information (not EXIF-Data) of an Image
class ImageUpdateDialog extends StatefulWidget {
  final int imageId;

  const ImageUpdateDialog({
    super.key,
    required this.imageId,
  });

  @override
  State<StatefulWidget> createState() {
    return _ImageUpdateDialogState();
  }
}

class _ImageUpdateDialogState extends State<ImageUpdateDialog> {
  late SingleValueDropDownController ratingController;
  late SingleValueDropDownController creatorController;
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
    ratingController.dispose();
    creatorController.dispose();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(4.0),
      child: FutureBuilder<api.Image>(
          future: ImageService.getImageInformation(widget.imageId),
          builder: (BuildContext context, AsyncSnapshot<api.Image> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              api.Image image = snapshot.data!;
              rating = image.rating ?? 0;
              String ratingInitValue = '$rating';
              int index = constants.ratingValues.indexWhere((element) => ratingInitValue == element.value);
              if (index != -1) {
                ratingController = SingleValueDropDownController(data: constants.ratingValues[index]);
              } else {
                ratingController = SingleValueDropDownController();
              }
              if (image.creator == null || image.creator!.isEmpty) {
                creatorController = SingleValueDropDownController();
                creator = '';
              } else {
                creatorController = SingleValueDropDownController(
                    data: DropDownValueModel(name: image.creator!, value: image.creator!));
                creator = image.creator ?? '';
              }
              keywords = (image.keywords == null) ? [] : image.keywords!.toList();
              title = image.title ?? '';
              description = image.description ?? '';
              return Form(
                child: ListView(
                children: [
                  textFormField(
                      'Datum',
                      (image.creationDate == null)
                          ? ''
                          : DateFormat.yMd('DE_de')
                              .add_Hms()
                              .format(image.creationDate!)),
                  textFormField(AppLocalizations.of(context)!.searchId, '${image.id}'),
                  textFormField(AppLocalizations.of(context)!.searchName, image.name),
                  textFormEditField(
                      labelText:  AppLocalizations.of(context)!.searchTitle,
                      value:  image.title ?? '',
                      onChanged: (String value) {
                        title = value;
                    }
                  ),
                  textFormEditField(
                      labelText: AppLocalizations.of(context)!.searchDescription,
                      value: image.description ?? '',
                      onChanged: (String value) {description = value;}),
                  KeywordWidget(
                    defaultValues: keywords,
                    result: keywords,
                    labelText: AppLocalizations.of(context)!.searchKeywords,
                    values: keywordHolder,
                  ),
                  DropDownTextField(
                    controller: ratingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    clearOption: true,
                    enableSearch: false,
                    dropDownItemCount: 6,
                    textFieldDecoration: InputDecoration(labelText: AppLocalizations.of(context)!.searchRating),
                    dropDownList: constants.ratingValues,
                    onChanged: (value) {
                      if (value == null || value is String) {
                        rating = 0;
                      } else {
                        rating = parseInt((value as DropDownValueModel).value);
                      }
                    },
                  ),
                  DropDownTextFieldDynamic(
                    controller: creatorController,
                    dropDownList: creators,
                    labelText: AppLocalizations.of(context)!.searchCreator,
                    onChanged: (String value) {
                      creator = value;
                    },
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ImageService.update(
                            imageId: widget.imageId,
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
