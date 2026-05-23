import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_scheduler_table/time_scheduler_table.dart';

class ShedulingCalendar extends StatefulWidget {
  const ShedulingCalendar({
    super.key,
    this.id,
    required this.isPerson,
    required this.dataStart,
    required this.dataEnd,
  });

  final String? id;
  final bool isPerson;
  final double dataStart;
  final double dataEnd;

  @override
  State<ShedulingCalendar> createState() => _ShedulingCalendarState();
}

class _ShedulingCalendarState extends State<ShedulingCalendar> {
  List<Event> eventList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void didUpdateWidget(covariant ShedulingCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id ||
        oldWidget.isPerson != widget.isPerson ||
        oldWidget.dataStart != widget.dataStart ||
        oldWidget.dataEnd != widget.dataEnd) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    if (widget.id == null || widget.id!.isEmpty) return;

    final type = widget.isPerson ? 'person' : 'group';
    final start = DateFormat('yyyy.MM.dd').format(
      DateTime.now().add(Duration(days: widget.dataStart.ceil())),
    );
    final finish = DateFormat('yyyy.MM.dd').format(
      DateTime.now().add(Duration(days: widget.dataEnd.ceil())),
    );

    final uri = Uri.https('ruz.fa.ru', '/api/schedule/$type/${widget.id}', {
      'start': start,
      'finish': finish,
    });

    try {
      final response = await Dio().getUri(uri);
      if (response.statusCode == 200 && response.data is List) {
        final data = List<dynamic>.from(response.data);
        if (!mounted) return;
        setState(() {
          eventList = List<Event>.from(
            data.map<Event>(
              (dynamic e) =>
                  Event.fromJson(Map<String, dynamic>.from(e as Map)),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Calendar load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade100,
      child: eventList.isEmpty
          ? const Center(child: Text('Нет занятий в выбранном периоде'))
          : TimeSchedulerTable(
              eventList: eventList,
              cellHeight: 52,
              cellWidth: 64,
              currentColumnTitleIndex: DateTime.now().weekday - 1,
              columnLabels: const [
                'Пн',
                'Вт',
                'Ср',
                'Чт',
                'Пт',
                'Сб',
                'Вс',
              ],
              rowLabels: const [
                '08:30 - 10:00',
                '10:10 - 11:40',
                '11:50 - 13:20',
                '14:00 - 15:30',
                '15:40 - 17:10',
                '17:20 - 18:50',
                '18:55 - 20:25',
                '20:30 - 22:00',
              ],
              eventAlert: EventAlert(),
            ),
    );
  }
}
