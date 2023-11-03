import 'package:digikam/bloc/setting_events.dart';
import 'package:digikam/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings.dart';

class SettingsStartupDialog extends StatelessWidget {

  const SettingsStartupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = "Digikam";
    return
      MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: const SettingsStartupMask(),
      ),
    );
  }
}

class SettingsStartupMask extends StatefulWidget {

  const SettingsStartupMask({super.key});

  @override
  SettingsStartupState createState() {
    return SettingsStartupState();
  }

}

class SettingsStartupState extends State<SettingsStartupMask> {

  final _formKey = GlobalKey<FormState>();

  String _urlStore = 'http://192.168.0.219:8081/digikambackend/rest';
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container (
        padding: const EdgeInsets.all(4.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _urlStore,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (String value) {
                  _urlStore = value;
                },
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
                      context.read<SettingsBloc>().add(SettingsFinishedEvent(
                        settings: Settings(url: _urlStore, darkMode: _darkMode)
                      ));
                    }
                  },
                  child: const Text('Speichern'),
                ),
                const SizedBox(
                  width: 4,
                ),
              ])
            ],
          ),

        ),

      ),
    );
  }

}