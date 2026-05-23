import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furshed/bloc/schedule_bloc.dart';
import 'package:furshed/providers/schedule_settings.dart';
import 'package:furshed/widgets/lesson_card.dart';
import 'package:furshed/widgets/schedule_calendar_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Расписание выбранной сущности: список или календарь (BLoC + Provider).
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    super.key,
    required this.entityType,
    required this.entityId,
    this.title,
  });

  final String entityType;
  final String entityId;
  final String? title;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _showCalendar = false;
  late int _dayStart;
  late int _dayEnd;

  @override
  void initState() {
    super.initState();
    final settings = context.read<ScheduleSettings>();
    _dayStart = settings.dayStartOffset;
    _dayEnd = settings.dayEndOffset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  void _load() {
    context.read<ScheduleBloc>().add(
          ScheduleLoadRequested(
            entityId: widget.entityId,
            isPerson: widget.entityType == 'person',
            dayStartOffset: _dayStart,
            dayEndOffset: _dayEnd,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = widget.title ?? 'Расписание';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: _showCalendar ? 'Список' : 'Календарь',
            icon: Icon(
              _showCalendar ? Icons.list : Icons.calendar_month_outlined,
            ),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: RangeSlider(
                    values: RangeValues(
                      _dayStart.toDouble(),
                      _dayEnd.toDouble(),
                    ),
                    min: -14,
                    max: 14,
                    divisions: 28,
                    labels: RangeLabels('$_dayStart', '$_dayEnd'),
                    onChanged: (v) {
                      setState(() {
                        _dayStart = v.start.round();
                        _dayEnd = v.end.round();
                      });
                    },
                    onChangeEnd: (_) {
                      context.read<ScheduleSettings>().setDateRange(
                            _dayStart,
                            _dayEnd,
                          );
                      _load();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ScheduleFailure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (state is! ScheduleLoaded) {
                  return const Center(
                    child: Text('Выберите преподавателя или группу'),
                  );
                }
                if (state.lessons.isEmpty) {
                  return const Center(child: Text('Занятий не найдено'));
                }
                if (_showCalendar) {
                  final weekStart = DateTime.now().add(Duration(days: _dayStart));
                  return ScheduleCalendarView(
                    lessons: state.lessons,
                    weekStart: weekStart,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.lessons.length,
                  itemBuilder: (_, i) => LessonCard(lesson: state.lessons[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
