import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../drawer_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../settings.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    String title = AppLocalizations.of(context)!.settingsTitle;
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        drawer: const DrawerWidget(),
        body: const SettingsMask(),
      ),
    );
  }
}

class SettingsMask extends StatefulWidget {
  const SettingsMask({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return SettingsMaskState();
  }
}

class SettingsMaskState extends State<SettingsMask> {
  final _formKey = GlobalKey<FormState>();

  late Settings _settings;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(4.0),
      child: buildFutureBuilder(),
    ));
  }

  FutureBuilder<Settings> buildFutureBuilder() {
    return FutureBuilder(
      future: SettingsRepository().getSettings(),
      builder: (BuildContext context, AsyncSnapshot<Settings> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          _settings = snapshot.data!;
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _settings.url,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (String? newValue) {
                    _settings.url = newValue ?? '';
                    },
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsUrl),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    }
                    return AppLocalizations.of(context)!.settingsUrlValidation;
                  },
                ),
                CheckboxListTile(
                    title: const Text("DarkMode"),
                    value: _settings.darkMode,
                    onChanged: (bool? newValue) {
                        setState(() {
                          _settings.darkMode = newValue!;
                        });
                     },
                     controlAffinity: ListTileControlAffinity.trailing,
                ),
                Row(children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        SettingsRepository().saveSettings(_settings);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.commonSave),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.commonQuit),
                  ),
                ])
              ],
            ),
          );
        }
      },
    );
  }


 }
