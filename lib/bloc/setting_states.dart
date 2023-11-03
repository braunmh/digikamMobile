import 'package:equatable/equatable.dart';

abstract class SettingState extends Equatable {

  @override
  List<Object> get props => [];
}

class SettingInitializeState extends SettingState {}

class SettingLoadState extends SettingState {}

class SettingCompletedState extends SettingState {}

class SettingErrorState extends SettingState {}