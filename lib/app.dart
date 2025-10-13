import 'package:flutter/material.dart';

import 'package:app/theme.dart';
import 'package:app/ui/routes/routes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      theme: ThemeData(colorScheme: AppTheme.darkScheme()),
    );
  }
}
