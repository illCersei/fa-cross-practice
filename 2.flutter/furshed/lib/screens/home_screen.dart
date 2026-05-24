import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:furshed/app_theme.dart';
import 'package:furshed/config/ruz_api_config.dart';
import 'package:furshed/models/ruz_search_result.dart';
import 'package:furshed/providers/schedule_settings.dart';
import 'package:furshed/services/ruz_api.dart';
import 'package:furshed/widgets/debounced_search_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Поиск преподавателя / группы (searchable_list + Provider).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ScheduleSettings>();
    final api = context.read<RuzApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание ФА'),
        flexibleSpace: Container(decoration: AppTheme.appBarDecoration()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FlutterSwitch(
              activeText: 'Лектор',
              inactiveText: 'Группа',
              inactiveColor: const Color(0xFF2E7D32),
              activeColor: const Color(0xFF66BB6A),
              value: settings.isPerson,
              width: 130,
              height: 30,
              onToggle: settings.setSearchType,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.isPerson
                            ? 'Поиск преподавателя'
                            : 'Поиск учебной группы',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: DebouncedSearchBar<RuzSearchResult>(
                          key: ValueKey<bool>(settings.isPerson),
                          hintText: settings.isPerson
                              ? 'Фамилия, например Иванов'
                              : 'Группа, например ПИ21-5',
                          resultToString: (r) => r.label,
                          resultTitleBuilder: (r) => Text(r.label),
                          resultSubtitleBuilder: (r) => Text(
                            r.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          searchFunction: (query) => api.search(
                            term: query,
                            isPerson: settings.isPerson,
                          ),
                          onResultSelected: (result) {
                            if (!context.mounted) return;
                            settings.select(result);
                            context.push(
                              '/schedule/${result.scheduleType}/${result.id}',
                              extra: result.label,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.touch_app_outlined,
              size: 36,
              color: Colors.green.shade700.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Введите запрос и выберите строку из списка',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            if (kIsWeb || RuzApiConfig.useProxy) ...[
              const SizedBox(height: 16),
              Text(
                'Web / CORS: запустите прокси и флаг USE_PROXY=true',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
