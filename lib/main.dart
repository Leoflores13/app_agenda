import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_config.dart';
import 'views/calendario_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(MeuApp());
}

class MeuApp extends StatefulWidget {
  static void atualizar(BuildContext context) {
    final state = context.findAncestorStateOfType<_MeuAppState>();
    state?.rebuild();
  }

  @override
  _MeuAppState createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda',
      theme: ThemeData(
        primaryColor: AppConfig.primaryColor,
        scaffoldBackgroundColor: AppConfig.backgroundColor,

        appBarTheme: AppBarTheme(
          backgroundColor: AppConfig.primaryColor,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.buttonColor,
          ),
        ),
      ),
      home: CalendarioPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}