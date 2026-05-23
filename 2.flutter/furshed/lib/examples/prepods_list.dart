import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:furshed/examples/sheduling_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'group_list_body.dart';

class Prepods {
  String id;
  String label;
  String description;

  Prepods({required this.id, required this.label, required this.description});

  factory Prepods.fromJson(Map<String, dynamic> json) {
    return Prepods(
      id: (json['id'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  /// [isPerson] true — преподаватель, false — группа (как в оригинале: status).
  static Future<Iterable<Prepods>> search(String query, bool isPerson) async {
    if (query.trim().isEmpty) {
      return <Prepods>[];
    }
    final type = isPerson ? 'person' : 'group';
    final uri = Uri.https('ruz.fa.ru', '/api/search', {
      'type': type,
      'term': query,
    });

    try {
      final response = await Dio().getUri(uri);
      if (response.statusCode == 200 && response.data is List) {
        final data = List<dynamic>.from(response.data);
        return List<Prepods>.from(
          data.map<Prepods>(
            (dynamic e) => Prepods.fromJson(Map<String, dynamic>.from(e)),
          ),
        );
      }
      throw Exception('Ошибка поиска: ${response.statusCode}');
    } catch (error, stackTrace) {
      debugPrint('Search request failed: $error');
      debugPrint('StackTrace: $stackTrace');
      return <Prepods>[];
    }
  }
}

class PrepodsList extends StatelessWidget {
  const PrepodsList({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrepodsListBody();
  }
}

class PrepodsListBody extends StatefulWidget {
  const PrepodsListBody({super.key});

  @override
  State<PrepodsListBody> createState() => _PrepodsListBodyState();
}

class _PrepodsListBodyState extends State<PrepodsListBody> {
  final _searchController = TextEditingController();

  Prepods? _selectedItem;
  Timer? _debounce;
  int _searchGen = 0;

  bool _isLoading = true;
  bool _calendar = true;
  /// false = группа, true = лектор (как в оригинале: status по умолчанию false).
  bool _isPerson = false;
  double _start = 0;
  double _end = 0;

  bool _searching = false;
  List<Prepods> _searchHits = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final gen = ++_searchGen;

    if (query.trim().isEmpty) {
      setState(() {
        _searching = false;
        _searchHits = [];
      });
      return;
    }

    setState(() => _searching = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted || gen != _searchGen) return;
      final results = await Prepods.search(query, _isPerson);
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _searching = false;
        _searchHits = results.toList();
      });
    });
  }

  void _selectPrepod(Prepods item) {
    _debounce?.cancel();
    _searchGen++;
    _searchController.text = item.label;
    setState(() {
      _selectedItem = item;
      _isLoading = false;
      _searchHits = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _calendar = !_calendar),
        tooltip: 'Календарь / список',
        child: Icon(
          _calendar ? Icons.calendar_month_outlined : Icons.list,
        ),
      ),
      appBar: AppBar(
        title: const Text('Расписание'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade400, Colors.green.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.green.shade100,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: _isPerson
                          ? 'Фамилия преподавателя'
                          : 'Название группы (например ПИ21-5)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                FlutterSwitch(
                  activeText: 'Лектор',
                  inactiveText: 'Группа',
                  inactiveColor: Colors.green,
                  value: _isPerson,
                  width: 120,
                  height: 30,
                  onToggle: (val) {
                    setState(() {
                      _isPerson = val;
                      _searchHits = [];
                      _selectedItem = null;
                      _isLoading = true;
                      _searchController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RangeSlider(
              values: RangeValues(_start, _end),
              min: -14,
              max: 14,
              divisions: 28,
              labels: RangeLabels(
                _start.round().toString(),
                _end.round().toString(),
              ),
              onChanged: (v) => setState(() {
                _start = v.start;
                _end = v.end;
              }),
            ),
          ),
          if (_searchHits.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchHits.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _searchHits[index];
                    return ListTile(
                      title: Text(item.label),
                      subtitle: Text(item.description),
                      onTap: () => _selectPrepod(item),
                    );
                  },
                ),
              ),
            ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Icon(
                      Icons.swipe_up_outlined,
                      size: 80,
                      color: Colors.black87,
                    ),
                  )
                : _calendar
                    ? GroupListBody(
                        thisselectedCategory: _selectedItem!.id,
                        thisselectedstatus: _isPerson,
                        thisdatastart: _start,
                        thisdataend: _end,
                      )
                    : ShedulingCalendar(
                        id: _selectedItem!.id,
                        isPerson: _isPerson,
                        dataStart: _start,
                        dataEnd: _end,
                      ),
          ),
        ],
      ),
    );
  }
}
