import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digikam/bloc/setting_events.dart';
import 'package:digikam/bloc/setting_states.dart';
import 'package:digikam/settings.dart';

class SettingsBloc extends Bloc<SettingEvent, SettingState> {
  final SettingsRepository repository;
  
  SettingsBloc({required this.repository}) : super(SettingInitializeState()) {
    on<SettingsStartedEvent>(_settingsStarted);
    on<SettingsErrorEvent>(_settingsError);
    on<SettingsFinishedEvent>(_settingsFinished);
  }

  Future<void> _settingsStarted(SettingsStartedEvent event, Emitter<SettingState> emit) async {
    Settings settings = await repository.getSettings();
    if (settings.isValid()) {
      return emit(SettingCompletedState());
    } else {
      return emit(SettingErrorState());
    }
  }

  Future<void> _settingsFinished(SettingsFinishedEvent event, Emitter<SettingState> emit) async {
    await repository.saveSettings(event.settings);
    return emit(SettingCompletedState());
  }

  void _settingsError(SettingsErrorEvent event, Emitter<SettingState> emit) {
    return emit(SettingErrorState());
  }
}