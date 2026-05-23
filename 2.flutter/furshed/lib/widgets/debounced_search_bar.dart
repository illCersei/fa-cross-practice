import 'dart:async';

import 'package:flutter/material.dart';

typedef DebouncedSearchFunction<T> = Future<Iterable<T>> Function(String query);

/// Поиск с debounce без SearchAnchor (стабильно при навигации go_router).
class DebouncedSearchBar<T> extends StatefulWidget {
  const DebouncedSearchBar({
    super.key,
    this.hintText,
    required this.resultToString,
    required this.resultTitleBuilder,
    required this.searchFunction,
    this.resultSubtitleBuilder,
    this.onResultSelected,
  });

  final String? hintText;
  final String Function(T result) resultToString;
  final Widget Function(T result) resultTitleBuilder;
  final Widget Function(T result)? resultSubtitleBuilder;
  final DebouncedSearchFunction<T> searchFunction;
  final void Function(T result)? onResultSelected;

  @override
  State<DebouncedSearchBar<T>> createState() => _DebouncedSearchBarState<T>();
}

class _DebouncedSearchBarState<T> extends State<DebouncedSearchBar<T>> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _debounce;
  int _generation = 0;
  bool _loading = false;
  String? _error;
  List<T> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    final gen = ++_generation;

    if (query.trim().isEmpty) {
      setState(() {
        _loading = false;
        _error = null;
        _results = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted || gen != _generation) return;
      try {
        final items = await widget.searchFunction(query);
        if (!mounted || gen != _generation) return;
        setState(() {
          _loading = false;
          _results = items.toList();
        });
      } catch (e) {
        if (!mounted || gen != _generation) return;
        setState(() {
          _loading = false;
          _error = e.toString();
          _results = [];
        });
      }
    });
  }

  void _select(T result) {
    _debounce?.cancel();
    _generation++;
    _focusNode.unfocus();
    _textController.text = widget.resultToString(result);
    setState(() {
      _loading = false;
      _results = [];
      _error = null;
    });
    widget.onResultSelected?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _textController.clear();
                          _onQueryChanged('');
                        },
                      )
                    : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _onQueryChanged,
          onSubmitted: (_) => _focusNode.unfocus(),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_results.isNotEmpty)
          Flexible(
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return ListTile(
                    title: widget.resultTitleBuilder(result),
                    subtitle: widget.resultSubtitleBuilder?.call(result),
                    onTap: () => _select(result),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
