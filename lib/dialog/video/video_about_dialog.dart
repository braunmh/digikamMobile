import 'package:built_collection/built_collection.dart';
import 'package:digikam/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_local;
import 'package:openapi/openapi.dart' as api;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Displays Information About an Image
class AboutVideoDialog extends StatefulWidget {
  final int videoId;

  const AboutVideoDialog({
    super.key,
    required this.videoId,
  });

  @override
  State<StatefulWidget> createState() {
    return _AboutVideoDialogState();
  }
}

class _AboutVideoDialogState extends State<AboutVideoDialog> {
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
                  textFormField(AppLocalizations.of(context)!.searchTitle, video.title),
                  textFormField(AppLocalizations.of(context)!.searchDescription, video.description),
                  textFormField(AppLocalizations.of(context)!.searchKeywords, '${_toList(video.keywords)}'),
                  textFormField(AppLocalizations.of(context)!.searchRating, '${video.rating}'),
                  textFormField(AppLocalizations.of(context)!.searchCreator, video.creator),
                  textFormField(
                      '${AppLocalizations.of(context)!.searchHeight} x ${AppLocalizations.of(context)!.searchHeight}',
                      '${video.height} x ${video.width}'),
                  textFormField(AppLocalizations.of(context)!.searchLongitude, _formatGeo(video.longitude)),
                  textFormField(AppLocalizations.of(context)!.searchLatitude, _formatGeo(video.latitude)),
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

  List<String> _toList(BuiltList<api.Keyword>? keywords) {
    if (keywords == null) {
      return [];
    }
    return keywords.map((k) => k.name).toList();
  }

  String _formatGeo(double? coordinate) {
    return (coordinate == null) ? '' : '$coordinate °';
  }

}
