# Расписание ФА (furshed)

Законченное приложение «Расписание» для ruz.fa.ru.

## Использованные этапы курса

| Этап | Реализация в проекте |
|------|---------------------|
| statefull | `ScheduleScreen`, переключение список/календарь |
| flutter_calendar_view / time_scheduler_table | `ScheduleCalendarView` |
| provider | `ScheduleSettings` — выбор сущности и диапазон дат |
| news_list | `LessonCard` — карточки занятий |
| netbloc / flbloc | `ScheduleBloc` — загрузка расписания |
| searchable_list | `DebouncedSearchBar`, модуль `searchable_list/searcheable_list` |
| go_router | `lib/router/app_router.dart` |

## Запуск (Windows)

```bash
cd 2.flutter/furshed
flutter pub get
flutter run -d windows
```

## Прокси (Web / Chrome / CORS)

```bash
dart run first/flutter_application_1/server.dart
cd furshed
flutter run -d chrome --dart-define=USE_PROXY=true
```

## Функции

- Поиск преподавателя или группы (debounced)
- Переход к расписанию по `go_router`
- Список занятий или недельная сетка
- Сдвиг периода ±14 дней
