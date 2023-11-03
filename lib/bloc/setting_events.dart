import 'package:equatable/equatable.dart';

import '../settings.dart';

abstract class SettingEvent extends Equatable {

  const SettingEvent();
  @override
  List<Object> get props => [];
}

class SettingsStartedEvent extends SettingEvent {

  @override
  String toString() => 'App started';
}

class SettingsErrorEvent extends SettingEvent {
  @override
  String toString() {
    return "Settings error";
  }
}

class SettingsFinishedEvent extends SettingEvent {

  final Settings settings;

  const SettingsFinishedEvent({required this.settings});

  @override
  String toString() => 'Settings finished';
}