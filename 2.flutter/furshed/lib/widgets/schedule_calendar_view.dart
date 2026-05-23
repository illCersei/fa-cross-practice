import 'package:flutter/material.dart';
import 'package:furshed/models/lesson.dart';
import 'package:intl/intl.dart';
import 'package:time_scheduler_table/time_scheduler_table.dart';

/// Недельная сетка (time_scheduler_table + flutter_calendar_view).
class ScheduleCalendarView extends StatelessWidget {
  const ScheduleCalendarView({
    super.key,
    required this.lessons,
    required this.weekStart,
  });

  final List<Lesson> lessons;
  final DateTime weekStart;

  static const _rowLabels = [
    '08:30 - 10:00',
    '10:10 - 11:40',
    '11:50 - 13:20',
    '14:00 - 15:30',
    '15:40 - 17:10',
    '17:20 - 18:50',
    '18:55 - 20:25',
    '20:30 - 22:00',
  ];

  List<String> get _columnLabels {
  final labels = <String>[];
    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      labels.add(DateFormat('E dd.MM', 'ru').format(day));
    }
    return labels;
  }

  List<Event> _toEvents() {
    return lessons.map((lesson) {
      final json = {
        'discipline': lesson.discipline,
        'group': lesson.group,
        'date': lesson.date,
        'beginLesson': lesson.beginLesson,
      };
      return Event.fromJson(json);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Center(child: Text('Занятий в выбранном периоде нет'));
    }
    return TimeSchedulerTable(
      eventList: _toEvents(),
      cellHeight: 52,
      cellWidth: 64,
      currentColumnTitleIndex:
          DateTime.now().difference(weekStart).inDays.clamp(0, 6),
      columnLabels: _columnLabels,
      rowLabels: _rowLabels,
      eventAlert: EventAlert(),
    );
  }
}
