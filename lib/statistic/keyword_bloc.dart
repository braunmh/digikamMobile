import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openapi/openapi.dart';

import '../settings.dart';

abstract class KeywordStatisticEvent extends Equatable {
  const KeywordStatisticEvent();

  @override
  List<Object> get props => [];
}

class KeywordStatisticInitializedEvent extends KeywordStatisticEvent {}

class KeywordStatisticStartedEvent extends KeywordStatisticEvent {
  final int keywordId;
  final int year;

  const KeywordStatisticStartedEvent(
      {required this.keywordId, required this.year});
}

class KeywordStatisticFinishedEvent extends KeywordStatisticEvent {}

class KeywordStatisticErrorEvent extends KeywordStatisticEvent {
  final String message;

  const KeywordStatisticErrorEvent({required this.message});

  @override
  List<Object> get props => [message];
}

abstract class KeywordStatisticState extends Equatable {
  @override
  List<Object> get props => [];
}

class KeywordStatisticInitializedState extends KeywordStatisticState {}

class KeywordStatisticKeywordStatisticState extends KeywordStatisticState {}

class KeywordStatisticErrorState extends KeywordStatisticState {
  final String msg;

  KeywordStatisticErrorState({required this.msg});
}

class KeywordStatisticNoDataState extends KeywordStatisticState {}

class KeywordStatisticDataState extends KeywordStatisticState {
  final List<StatisticKeyword> list;

  KeywordStatisticDataState({required this.list});
}

class KeywordStatisticBloc
    extends Bloc<KeywordStatisticEvent, KeywordStatisticState> {
  KeywordStatisticBloc() : super(KeywordStatisticInitializedState()) {
    on<KeywordStatisticInitializedEvent>(_initialized);
    on<KeywordStatisticStartedEvent>(_started);
    on<KeywordStatisticFinishedEvent>(_finished);
    on<KeywordStatisticErrorEvent>(_error);
  }

  void _initialized(KeywordStatisticInitializedEvent event,
      Emitter<KeywordStatisticState> emit) {
    emit(KeywordStatisticInitializedState());
  }

  Future<void> _started(KeywordStatisticStartedEvent event,
      Emitter<KeywordStatisticState> emit) async {
    ImageApi api =
        Openapi(basePathOverride: SettingsFactory().settings.url).getImageApi();
    final response =
        await api.statKeyword(keywordId: event.keywordId, year: event.year);
    if (response.statusCode == 200) {
      if (response.data!.toList().isEmpty) {
        emit(KeywordStatisticNoDataState());
      } else {
        emit(KeywordStatisticDataState(list: response.data!.toList()));
      }
    } else {
      emit(KeywordStatisticErrorState(
          msg: response.statusMessage ?? 'StatusCode ${response.statusCode}'));
    }
  }

  void _finished(KeywordStatisticFinishedEvent event,
      Emitter<KeywordStatisticState> emit) {}

  void _error(
      KeywordStatisticErrorEvent event, Emitter<KeywordStatisticState> emit) {}
}
