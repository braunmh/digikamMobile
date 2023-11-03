import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../drawer_widget.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = "Einstellungen";
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        drawer: const DrawerWidget(),
        body: const SettingsMask(),
      ),
    );
  }
}

class SettingsMask extends StatefulWidget {
  const SettingsMask({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingsMaskState();
  }
}

class SettingsMaskState extends State<SettingsMask> {
  final _formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _urlStore = '';
  bool _darkMode = false;

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

  FutureBuilder<String> buildFutureBuilder() {
    return FutureBuilder(
      future: _getUrl(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          _urlStore = snapshot.data!;
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _urlStore,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: _onSubmittedUrl,
                  decoration: const InputDecoration(labelText: 'Backend-Url'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    }
                    return "Bitte geben Sie eine URl an.";
                  },
                ),
                CheckboxListTile(
                    title: const Text("DarkMode"),
                    value: _darkMode,
                    onChanged: (bool? newValue) {
                        setState(() {
                          _darkMode = newValue!;
                        });
                     },
                     controlAffinity: ListTileControlAffinity.trailing,
                ),
                Row(children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _save();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Speichern'),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Abbrechen'),
                  ),
                ])
              ],
            ),
          );
        }
      },
    );
  }

  void _save() async {
    await _prefs
        .then((SharedPreferences prefs) => prefs.setString('url', _urlStore));
  }

  void _onSubmittedUrl(String value) {
    _urlStore = value;
  }

  Future<String> _getUrl() => _prefs.then((SharedPreferences prefs) {
        return prefs.getString('url') ??
            'http://192.168.0.219:8081/digikambackend/rest';
      });
}
