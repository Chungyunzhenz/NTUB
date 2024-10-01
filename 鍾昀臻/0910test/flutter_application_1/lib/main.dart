import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_notifier.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(isDarkMode),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: '紙張小精靈',
          theme: ThemeData(
            colorScheme: themeNotifier.isDarkMode
                ? const ColorScheme.dark(
                    primary: Colors.indigo,
                    secondary: Colors.indigoAccent,
                  )
                : const ColorScheme.light(
                    primary: Colors.blue,
                    secondary: Colors.blueAccent,
                  ),
            textTheme: themeNotifier.isDarkMode
                ? Typography.whiteMountainView
                : Typography.blackMountainView,
          ),
          home: LoginPage(),
        );
      },
    );
  }
}
