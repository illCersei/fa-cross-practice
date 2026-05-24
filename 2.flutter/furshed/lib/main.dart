import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furshed/app_theme.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleSettings()),
        Provider(create: (_) => RuzApi()),
      ],
      child: BlocProvider(
        create: (context) => ScheduleBloc(context.read<RuzApi>()),
        child: MaterialApp.router(
          title: 'Расписание ФА',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: createAppRouter(),
        ),
      ),
    );
  }
}
