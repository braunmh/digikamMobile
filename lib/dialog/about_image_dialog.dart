import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_local;
import 'package:openapi/openapi.dart' as api;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Displays Information About an Image
class AboutImageDialog extends StatefulWidget {
  final String remoteUrl;
  final int imageId;

  const AboutImageDialog({
    super.key,
    required this.remoteUrl,
    required this.imageId,
  });

  @override
  State<StatefulWidget> createState() {
    return _AboutImageDialogState();
  }
}

class _AboutImageDialogState extends State<AboutImageDialog> {
  @override
  void initState() {
    super.initState();
    date_local.initializeDateFormatting('DE_de', null);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(4.0),
      child: FutureBuilder<api.Image>(
          future: getImageInformation(),
          builder: (BuildContext context, AsyncSnapshot<api.Image> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              api.Image image = snapshot.data!;
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
                  textFormField(AppLocalizations.of(context)!.searchDescription, image.description),
                  textFormField(AppLocalizations.of(context)!.searchKeywords, '${image.keywords}'),
                  textFormField(AppLocalizations.of(context)!.searchRating, '${image.rating}'),
                  textFormField(AppLocalizations.of(context)!.searchCreator, image.creator),
                  textFormField(AppLocalizations.of(context)!.searchCamera, '${image.make} ${image.model}'),
                  textFormField(AppLocalizations.of(context)!.searchLens, image.lens),
                  textFormField(
                      AppLocalizations.of(context)!.searchFocalLength, '${image.focalLength35} mm (35)'),
                  textFormField(
                      '${AppLocalizations.of(context)!.searchHeight} x ${AppLocalizations.of(context)!.searchHeight}',
                      '${image.height} x ${image.width}'),
                  textFormField(
                      AppLocalizations.of(context)!.searchExposureTime, _formatExposureTime(image.exposureTime)),
                  textFormField(AppLocalizations.of(context)!.searchIso, '${image.iso}'),
                  textFormField(
                      AppLocalizations.of(context)!.searchAperture,
                      (image.aperture == null)
                          ? ''
                          : '${image.aperture!}'),
                  textFormField(AppLocalizations.of(context)!.searchLongitude, _formatGeo(image.longitude)),
                  textFormField(AppLocalizations.of(context)!.searchLatitude, _formatGeo(image.latitude)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.commonClose),
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

  String _formatGeo(double? coordinate) {
    return (coordinate == null) ? '' : '$coordinate °';
  }

  String _formatExposureTime(double? time) {
    if (time == null || time == 0) {
      return '';
    }
    if (time >= 1) {
      return time.toInt().toString();
    }
    return '1 / ${1 / time}';
  }

  Future<api.Image> getImageInformation() async {
    api.ImageApi openApi =
        api.Openapi(basePathOverride: widget.remoteUrl).getImageApi();
    final response =
        await openApi.getInformationAboutImage(imageId: widget.imageId);
    if (200 == response.statusCode) {
      return response.data!;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }
}
