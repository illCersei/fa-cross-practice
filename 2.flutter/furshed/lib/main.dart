import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furshed/bloc/schedule_bloc.dart';
import 'package:furshed/providers/schedule_settings.dart';
import 'package:furshed/router/app_router.dart';
import 'package:furshed/services/ruz_api.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  runApp(const ScheduleApp());
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = RuzApi();
    return MultiProvider(
      providers: [
        Provider<RuzApi>.value(value: api),
        ChangeNotifierProvider(create: (_) => ScheduleSettings()),
        BlocProvider(create: (_) => ScheduleBloc(api)),
      ],
      child: MaterialApp.router(
        title: 'Расписание ФА',
        theme: ThemeData(
          colorSchemeSeed: Colors.green,
          useMaterial3: true,
        ),
        routerConfig: createAppRouter(),
      ),
    );
  }
}
