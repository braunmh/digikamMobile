import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digikam/services/backend_service.dart';
import 'package:equatable/equatable.dart';
import 'package:openapi/openapi.dart';

import '../util/range.dart';

abstract class SearchEvent extends Equatable {

  const SearchEvent();

  @override
  List<Object> get props => [];

}

class SearchInitializedEvent extends SearchEvent {
}

class SearchStartedEvent extends SearchEvent {
  final List<Keyword> keywords;
  final String? author;
  final String? camera;
  final String? lens;
  final String? orientation;
  final RowRangeIncompleteDate date;
  final RowRangeInt rating;
  final RowRangeInt iso;
  final RowRangeDouble exposureTime;
  final RowRangeDouble aperture;
  final RowRangeInt focalLength;

  const SearchStartedEvent({
    required this.keywords,
    this.author,
    this.camera,
    this.lens,
    this.orientation,
    required this.date,
    required this.rating,
    required this.iso,
    required this.exposureTime,
    required this.aperture,
    required this.focalLength,
  });

}

class SearchFinishedEvent extends SearchEvent {}

class SearchErrorEvent extends SearchEvent {

  final String message;

  const SearchErrorEvent({required this.message});

  @override
  List<Object> get props => [message];
}

abstract class SearchState extends Equatable {

  @override
  List<Object> get props => [];
}

class SearchInitializedState extends SearchState {}

class SearchSearchState extends SearchState {}

class SearchErrorState extends SearchState {
  final String msg;
  SearchErrorState({required this.msg});
}

class SearchNoDataState extends SearchState {}

class SearchDataState extends SearchState {

  final List<ImagesInner> list;

  SearchDataState({required this.list});
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {

  SearchBloc() : super(SearchInitializedState()) {
    on<SearchInitializedEvent>(_searchInitialized);
    on<SearchStartedEvent>(_searchStarted);
    on<SearchFinishedEvent>(_searchFinished);
    on<SearchErrorEvent>(_searchError);
  }

  void _searchInitialized(SearchInitializedEvent event,
      Emitter<SearchState> emit) {
      emit(SearchInitializedState());
  }

  Future<void> _searchStarted(SearchStartedEvent event,
      Emitter<SearchState> emit) async {
    final response = await ImageService.findImagesByImageAttributes(event);
    if (response.statusCode == 200) {
      if (response.data!.toList().isEmpty) {
        emit(SearchNoDataState());
      } else {
        emit(SearchDataState(list: response.data!.toList()));
      }
    } else {
      emit(SearchErrorState(msg: response.statusMessage ?? 'StatusCode ${response.statusCode}'));
    }
  }

  void _searchFinished(SearchFinishedEvent event,
      Emitter<SearchState> emit) {
  }

  void _searchError(SearchErrorEvent event,
      Emitter<SearchState> emit) {
  }
}