import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furshed/models/lesson.dart';
import 'package:furshed/services/ruz_api.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc(this._api) : super(const ScheduleInitial()) {
    on<ScheduleLoadRequested>(_onLoad);
  }

  final RuzApi _api;

  Future<void> _onLoad(
    ScheduleLoadRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    try {
      final lessons = await _api.fetchSchedule(
        entityId: event.entityId,
        isPerson: event.isPerson,
        dayStartOffset: event.dayStartOffset,
        dayEndOffset: event.dayEndOffset,
      );
      emit(ScheduleLoaded(lessons));
    } catch (e) {
      emit(ScheduleFailure(e.toString()));
    }
  }
}

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleLoadRequested extends ScheduleEvent {
  const ScheduleLoadRequested({
    required this.entityId,
    required this.isPerson,
    required this.dayStartOffset,
    required this.dayEndOffset,
  });

  final String entityId;
  final bool isPerson;
  final int dayStartOffset;
  final int dayEndOffset;

  @override
  List<Object?> get props =>
      [entityId, isPerson, dayStartOffset, dayEndOffset];
}

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  const ScheduleLoaded(this.lessons);

  final List<Lesson> lessons;

  @override
  List<Object?> get props => [lessons];
}

class ScheduleFailure extends ScheduleState {
  const ScheduleFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
