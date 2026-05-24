import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furshed/app_theme.dart';
import 'package:furshed/bloc/schedule_bloc.dart';
import 'package:furshed/providers/schedule_settings.dart';
import 'package:furshed/widgets/lesson_card.dart';
import 'package:furshed/widgets/schedule_calendar_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Расписание выбранной сущности: список или сетка (BLoC + Provider + statefull).
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

  @override
  void didUpdateWidget(covariant ScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entityId != widget.entityId ||
        oldWidget.entityType != widget.entityType) {
      _load();
    }
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
        flexibleSpace: Container(decoration: AppTheme.appBarDecoration()),
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
            tooltip: _showCalendar ? 'Список занятий' : 'Недельная сетка',
            icon: Icon(_showCalendar ? Icons.view_list : Icons.grid_on),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Colors.white,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Период: $_dayStart … $_dayEnd дн. от сегодня',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  RangeSlider(
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
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ScheduleFailure) {
                  return _MessagePanel(
                    icon: Icons.error_outline,
                    message: state.message,
                    onRetry: _load,
                  );
                }
                if (state is! ScheduleLoaded) {
                  return const _MessagePanel(
                    icon: Icons.search,
                    message: 'Выберите преподавателя или группу на главном экране',
                  );
                }
                if (state.lessons.isEmpty) {
                  return const _MessagePanel(
                    icon: Icons.event_busy,
                    message: 'Занятий в выбранном периоде нет',
                  );
                }
                if (_showCalendar) {
                  final weekStart =
                      DateTime.now().add(Duration(days: _dayStart));
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

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.green.shade700),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
