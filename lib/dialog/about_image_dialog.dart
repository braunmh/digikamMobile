import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_local;
import 'package:openapi/openapi.dart' as api;

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
                  textFormField('Id', '${image.id}'),
                  textFormField('Name', image.name),
                  textFormField('Beschreibung', image.description),
                  textFormField('Stichworte', '${image.keywords}'),
                  textFormField('Bewertung', '${image.rating}'),
                  textFormField('Urheber', image.creator),
                  textFormField('Kamera', '${image.make} ${image.model}'),
                  textFormField('Objektiv', image.lens),
                  textFormField(
                      'Brennweite', '${image.focalLength35} mm (35)'),
                  textFormField(
                      'Höhe x Breite', '${image.height} x ${image.width}'),
                  textFormField('ISO', '${image.iso}'),
                  textFormField(
                      'Belichtung', _formatExposureTime(image.exposureTime)),
                  textFormField('ISO', '${image.iso}'),
                  textFormField(
                      'Blende',
                      (image.aperture == null)
                          ? ''
                          : '${image.aperture!}'),
                  textFormField('Längengrad', _formatGeo(image.longitude)),
                  textFormField('Breitengrad', _formatGeo(image.latitude)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Schliessen'),
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
