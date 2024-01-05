
import 'package:digikam/dialog/settings_startup_dialog.dart';
import 'package:digikam/dialog/splash_screen.dart';
import 'package:digikam/services/backend_service.dart';
import 'package:digikam/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bloc/setting_events.dart';
import 'bloc/setting_states.dart';
import 'bloc/settings_bloc.dart';
import 'dialog/search_mask.dart';
import 'drawer_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioSingleton.init();
  runApp(const Startup());
}

class Startup extends StatefulWidget {
  const Startup({super.key});

  @override
  StartupState createState() {
    return StartupState();
  }
}

class StartupState extends State<Startup> {
  late SettingsRepository _settingsRepository;
  late SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsRepository = SettingsRepository();
    _settingsBloc = SettingsBloc(repository: _settingsRepository);
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: const Text('Digikam'),
    );
    return BlocProvider<SettingsBloc>(
        create: (context) => _settingsBloc,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'Digikam', //AppLocalizations.of(context)!.mainTitle,
          theme: ThemeData(
            useMaterial3: false,
            brightness: Brightness.dark,
//            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, background: Colors.blue)
          ),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: appBar,
            drawer: const DrawerWidget(),
            body: BlocBuilder<SettingsBloc, SettingState>(
              builder: (context, state) {
                if (state is SettingInitializeState) {
                  _settingsBloc.add(SettingsStartedEvent());
                  return const SplashScreen();
                } else if (state is SettingErrorState) {
                  return const SettingsStartupDialog();
                } else if (state is SettingCompletedState) {
                  return SearchMask(
                    appBarHeight: appBar.preferredSize.height,
                  );
                } else {
                  return const SplashScreen();
                }
              },
            ),
          ),
        )
    );
  }
}
