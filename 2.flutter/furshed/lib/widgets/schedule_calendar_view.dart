import 'package:flutter/material.dart';
import 'package:furshed/models/lesson.dart';
import 'package:intl/intl.dart';
import 'package:time_scheduler_table/time_scheduler_table.dart';

/// Недельная сетка занятий (time_scheduler_table).
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

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  List<Event> _toEvents() {
    final gridStart = _dateOnly(weekStart);
    final events = <Event>[];

    for (final lesson in lessons) {
      if (lesson.date.isEmpty || lesson.beginLesson.isEmpty) continue;

      try {
        final lessonDate = _dateOnly(Event.parseScheduleDate(lesson.date));
        final columnIndex = lessonDate.difference(gridStart).inDays;
        if (columnIndex < 0 || columnIndex > 6) continue;

        final begin = DateFormat('H:mm').parse(lesson.beginLesson);
        final rowIndex =
            (((begin.hour * 60 + begin.minute) / 96).toInt() - 5).clamp(0, 7);

        events.add(
          Event(
            title: lesson.discipline,
            time: lesson.group,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
          ),
        );
      } catch (_) {
        // Пропускаем занятия с некорректной датой/временем.
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _toEvents();
    if (events.isEmpty) {
      return const Center(
        child: Text('Занятий в выбранном периоде нет'),
      );
    }
    return TimeSchedulerTable(
      eventList: events,
      cellHeight: 52,
      cellWidth: 64,
      currentColumnTitleIndex:
          DateTime.now().difference(_dateOnly(weekStart)).inDays.clamp(0, 6),
      columnLabels: _columnLabels,
      rowLabels: _rowLabels,
      eventAlert: EventAlert(),
    );
  }
}
