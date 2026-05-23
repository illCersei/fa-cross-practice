import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:furshed/config/ruz_api_config.dart';
import 'package:furshed/models/ruz_search_result.dart';
import 'package:furshed/providers/schedule_settings.dart';
import 'package:furshed/services/ruz_api.dart';
import 'package:furshed/widgets/debounced_search_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Поиск преподавателя / группы (searchable_list + StatefulWidget).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ScheduleSettings>();
    final api = context.read<RuzApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание ФА'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade400, Colors.green.shade200],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FlutterSwitch(
              activeText: 'Лектор',
              inactiveText: 'Группа',
              inactiveColor: Colors.green,
              value: settings.isPerson,
              width: 130,
              height: 30,
              onToggle: settings.setSearchType,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: DebouncedSearchBar<RuzSearchResult>(
                key: ValueKey<bool>(settings.isPerson),
                hintText: settings.isPerson
                    ? 'Фамилия преподавателя'
                    : 'Название группы',
                resultToString: (r) => r.label,
                resultTitleBuilder: (r) => Text(r.label),
                resultSubtitleBuilder: (r) => Text(r.description),
                searchFunction: (query) =>
                    api.search(term: query, isPerson: settings.isPerson),
                onResultSelected: (result) {
                  if (!context.mounted) return;
                  context.push(
                    '/schedule/${result.scheduleType}/${result.id}',
                    extra: result.label,
                  );
                },
              ),
            ),
            const Icon(Icons.info_outline, size: 40, color: Colors.black54),
            const SizedBox(height: 8),
            Text(
              'Введите запрос и выберите строку из списка',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (kIsWeb || RuzApiConfig.useProxy) ...[
              const SizedBox(height: 12),
              const Text(
                'Для Web: dart run first/flutter_application_1/server.dart\n'
                'и flutter run --dart-define=USE_PROXY=true',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
