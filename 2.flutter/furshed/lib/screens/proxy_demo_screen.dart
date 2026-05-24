import 'package:flutter/material.dart';
import 'package:furshed/app_theme.dart';
import 'package:furshed/config/ruz_api_config.dart';
import 'package:furshed/examples/auditorium.dart';

/// Демо запросов через локальный прокси (first/flutter_application_1/server.dart).
class ProxyDemoScreen extends StatelessWidget {
  const ProxyDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Прокси ruz.fa.ru'),
        flexibleSpace: Container(decoration: AppTheme.appBarDecoration()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: RuzApiConfig.shouldUseProxy
                ? Colors.green.shade100
                : Colors.amber.shade100,
            child: Row(
              children: [
                Icon(
                  RuzApiConfig.shouldUseProxy
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: RuzApiConfig.shouldUseProxy
                      ? Colors.green.shade800
                      : Colors.amber.shade900,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    RuzApiConfig.shouldUseProxy
                        ? 'Прокси: localhost:3000'
                        : 'dart run first/flutter_application_1/server.dart\n'
                            'flutter run --dart-define=USE_PROXY=true',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: SchedulePage()),
        ],
      ),
    );
  }
}
