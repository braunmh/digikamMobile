import 'package:digikam/services/backend_service.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart' as date_local;
import 'package:openapi/openapi.dart' as api;
import '../../constants.dart' as constants;
import '../../l10n/app_localizations.dart';

/// Displays Information About an Image
class RateImageDialog extends StatefulWidget {
  final int imageId;

  const RateImageDialog({
    super.key,
    required this.imageId,
  });

  @override
  State<StatefulWidget> createState() {
    return _RateImageDialogState();
  }
}

class _RateImageDialogState extends State<RateImageDialog> {

  late SingleValueDropDownController controller;
  late int rating;

  @override
  void initState() {
    super.initState();
    date_local.initializeDateFormatting('DE_de', null);
//    controller = SingleValueDropDownController();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(4.0),
      child: FutureBuilder<api.Image>(
          future: ImageService.getImageInformation(widget.imageId),
          builder: (BuildContext context, AsyncSnapshot<api.Image> snapshot) {
            if (snapshot.hasError) {
              return Text(AppLocalizations.of(context)!
                  .messageError('${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              api.Image image = snapshot.data!;
              String initValue = '${image.rating ?? 0}';
              int index = constants.ratingValues.indexWhere((element) =>
                initValue == element.value);
              if (index != -1) {
                controller = SingleValueDropDownController(data: constants.ratingValues[index]);
              } else {
                controller = SingleValueDropDownController();
              }
              return Form(
                child: ListView(
                children: [
                  DropDownTextField(
                    controller: controller,
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
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ImageService.updateRating(widget.imageId, rating);
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

  int parseInt(String value) {
    try {
      return num.parse(value).toInt();
    } catch (e) {
      return 0;
    }
  }

}
