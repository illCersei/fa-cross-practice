# Расписание ФА (furshed)

Законченное приложение для [ruz.fa.ru](https://ruz.fa.ru).

## Этапы курса в проекте

| Этап | Реализация |
|------|------------|
| statefull | `ScheduleScreen` — переключение список / сетка |
| flutter_calendar_view | отдельный модуль `../flutter_calendar_view/example` |
| provider | `ScheduleSettings` в `lib/providers/` |
| news_list | `LessonCard` — карточки занятий |
| netbloc / flbloc | `ScheduleBloc` — загрузка расписания |
| time_scheduler_table | `ScheduleCalendarView` |
| searchable_list | `DebouncedSearchBar`, модуль `../searchable_list/searcheable_list` |
| go_router | `lib/router/app_router.dart`, `AppShell` |

## Запуск (Windows)

```bash
cd 2.flutter/furshed
flutter pub get
flutter run -d windows
```

## Прокси (Web / Chrome / CORS)

```bash
dart run first/flutter_application_1/server.dart
cd 2.flutter/furshed
flutter run -d chrome --dart-define=USE_PROXY=true
```

## Функции

- Поиск преподавателя или группы (debounce 500 ms)
- Переход к расписанию: `go_router` → `/schedule/:type/:id`
- Список занятий или недельная сетка
- Сдвиг периода ±14 дней
- Вкладка «Прокси» — демо через localhost
