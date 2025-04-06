import 'package:civic/Getstarted.dart';
import 'package:civic/theam_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized

  await Supabase.initialize(
    url: 'https://ygskgxxzdsxuphqjqqie.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlnc2tneHh6ZHN4dXBocWpxcWllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkwODI5NzksImV4cCI6MjA1NDY1ODk3OX0.vMIrNtmuOH0DQaMWNS1n0j9l4LedSb-42CoZgO8ifKg',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const Start(),
        );
      },
    );
  }
}
