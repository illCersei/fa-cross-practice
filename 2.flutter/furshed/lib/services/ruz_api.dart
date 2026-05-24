import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:furshed/config/ruz_api_config.dart';
import 'package:furshed/models/lesson.dart';
import 'package:furshed/models/ruz_search_result.dart';
import 'package:intl/intl.dart';

class RuzApi {
  RuzApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                headers: {'Accept': 'application/json'},
                responseType: ResponseType.json,
                validateStatus: (code) => code != null && code < 500,
              ),
            );

  final Dio _dio;

  Future<List<RuzSearchResult>> search({
    required String term,
    required bool isPerson,
  }) async {
    if (term.trim().isEmpty) {
      return [];
    }
    final type = isPerson ? 'person' : 'group';
    final response = await _dio.getUri(
      Uri.parse(RuzApiConfig.searchUrl(type, term.trim())),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка поиска: HTTP ${response.statusCode}');
    }

    final items = _extractList(response.data);
    return items
        .map(
          (dynamic e) => RuzSearchResult.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<List<Lesson>> fetchSchedule({
    required String entityId,
    required bool isPerson,
    required int dayStartOffset,
    required int dayEndOffset,
  }) async {
    final start = DateFormat('yyyy.MM.dd').format(
      DateTime.now().add(Duration(days: dayStartOffset)),
    );
    final finish = DateFormat('yyyy.MM.dd').format(
      DateTime.now().add(Duration(days: dayEndOffset)),
    );
    final type = isPerson ? 'person' : 'group';
    final response = await _dio.getUri(
      Uri.parse(RuzApiConfig.scheduleUrl(type, entityId, start, finish)),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка расписания: HTTP ${response.statusCode}');
    }

    final items = _extractList(response.data);
    return items
        .map(
          (dynamic e) => Lesson.fromJson(
            Map<String, dynamic>.from(e as Map),
            forPerson: isPerson,
          ),
        )
        .toList();
  }

  /// ruz.fa.ru отдаёт JSON-массив; Dio иногда возвращает String.
  static List<dynamic> _extractList(dynamic data) {
    if (data == null) {
      return [];
    }
    if (data is List) {
      return data;
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return [];
      }
      if (trimmed.startsWith('<')) {
        throw Exception('Сервер вернул HTML вместо JSON. Проверьте прокси или сеть.');
      }
      return _extractList(jsonDecode(trimmed));
    }
    if (data is Map) {
      for (final key in ['data', 'results', 'items']) {
        final nested = data[key];
        if (nested is List) {
          return nested;
        }
      }
    }
    throw Exception('Неожиданный формат ответа API');
  }
}
