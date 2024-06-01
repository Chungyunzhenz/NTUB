import 'package:flutter/material.dart';

class AssistantPage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AssistantPage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to Assistant Page')),
    );
  }
}
