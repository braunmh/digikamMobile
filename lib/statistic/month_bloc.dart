import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openapi/openapi.dart';
import '../settings.dart';

abstract class MonthStatisticEvent extends Equatable {
  const MonthStatisticEvent();

  @override
  List<Object> get props => [];
}

class MonthStatisticInitializedEvent extends MonthStatisticEvent {}

class MonthStatisticStartedEvent extends MonthStatisticEvent {}

class MonthStatisticFinishedEvent extends MonthStatisticEvent {}

class MonthStatisticErrorEvent extends MonthStatisticEvent {
  final String message;

  const MonthStatisticErrorEvent({required this.message});

  @override
  List<Object> get props => [message];
}

abstract class MonthStatisticState extends Equatable {
  @override
  List<Object> get props => [];
}

class MonthStatisticInitializedState extends MonthStatisticState {}

class MonthStatisticMonthStatisticState extends MonthStatisticState {}

class MonthStatisticErrorState extends MonthStatisticState {
  final String msg;

  MonthStatisticErrorState({required this.msg});
}

class MonthStatisticNoDataState extends MonthStatisticState {}

class MonthStatisticDataState extends MonthStatisticState {
  final MonthStatistic stat;

  MonthStatisticDataState({required this.stat});
}

class MonthStatistic {
  final int maxCount;
  List<StatisticMonth> list;

  MonthStatistic({required this.maxCount, required this.list});
}

class MonthStatisticBloc
    extends Bloc<MonthStatisticEvent, MonthStatisticState> {
  MonthStatisticBloc() : super(MonthStatisticInitializedState()) {
    on<MonthStatisticInitializedEvent>(_initialized);
    on<MonthStatisticStartedEvent>(_started);
    on<MonthStatisticFinishedEvent>(_finished);
    on<MonthStatisticErrorEvent>(_error);
  }

  void _initialized(
      MonthStatisticInitializedEvent event, Emitter<MonthStatisticState> emit) {
    emit(MonthStatisticInitializedState());
  }

  Future<void> _started(MonthStatisticStartedEvent event,
      Emitter<MonthStatisticState> emit) async {
    ImageApi api =
        Openapi(basePathOverride: SettingsFactory().settings.url).getImageApi();
    final response = await api.statMonth();
    if (response.statusCode == 200) {
      if (response.data!.toList().isEmpty) {
        emit(MonthStatisticNoDataState());
      } else {
        List<StatisticMonth> list = [];
        int year = response.data!.toList()[0].year;
        int count = 0;
        int maxCount = 0;
        for (StatisticMonth m in response.data!.toList()) {
          if (m.cnt> maxCount) {
            maxCount = m.cnt;
          }
          if (year != m.year) {
            list.add(StatisticMonth((b) {
              b.year = year;
              b.month = 0;
              b.cnt = count;
            }));
            year = m.year;
            count = 0;
          }
          count += m.cnt;
          list.add(m);
        }
        emit(MonthStatisticDataState(stat: MonthStatistic(maxCount: maxCount, list: list)));
      }
    } else {
      emit(MonthStatisticErrorState(
          msg: response.statusMessage ?? 'StatusCode ${response.statusCode}'));
    }
  }

  void _finished(
      MonthStatisticFinishedEvent event, Emitter<MonthStatisticState> emit) {}

  void _error(
      MonthStatisticErrorEvent event, Emitter<MonthStatisticState> emit) {}
}
