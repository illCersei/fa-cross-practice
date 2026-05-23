import 'package:dio/dio.dart';
import 'package:furshed/config/ruz_api_config.dart';
import 'package:furshed/models/lesson.dart';
import 'package:furshed/models/ruz_search_result.dart';
import 'package:intl/intl.dart';

class RuzApi {
  RuzApi({Dio? dio}) : _dio = dio ?? Dio();

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
    if (response.statusCode != 200 || response.data is! List) {
      throw Exception('Ошибка поиска: ${response.statusCode}');
    }
    return List<RuzSearchResult>.from(
      (response.data as List).map(
        (dynamic e) => RuzSearchResult.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      ),
    );
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
    if (response.statusCode != 200 || response.data is! List) {
      throw Exception('Ошибка расписания: ${response.statusCode}');
    }
    return List<Lesson>.from(
      (response.data as List).map(
        (dynamic e) => Lesson.fromJson(
          Map<String, dynamic>.from(e as Map),
          forPerson: isPerson,
        ),
      ),
    );
  }
}
