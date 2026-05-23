import 'package:flutter/foundation.dart';
import 'package:furshed/models/ruz_search_result.dart';

/// Provider: передача выбранной сущности и диапазона дат между экранами.
class ScheduleSettings extends ChangeNotifier {
  RuzSearchResult? selected;
  /// false = группа (как в оригинальном prepods_list: status по умолчанию).
  bool isPerson = false;
  int dayStartOffset = 0;
  int dayEndOffset = 7;
  bool showCalendar = false;

  void setSearchType(bool person) {
    if (isPerson == person) return;
    isPerson = person;
    selected = null;
    notifyListeners();
  }

  void setDateRange(int start, int end) {
    dayStartOffset = start;
    dayEndOffset = end;
    notifyListeners();
  }

  void select(RuzSearchResult item) {
    selected = item;
    isPerson = item.isPerson;
    notifyListeners();
  }

  void clearSelection() {
    selected = null;
    notifyListeners();
  }

  void toggleView() {
    showCalendar = !showCalendar;
    notifyListeners();
  }
}
