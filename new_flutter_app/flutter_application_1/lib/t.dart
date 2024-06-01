import 'package:flutter/material.dart';

class TeacherPage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const TeacherPage({
    super.key, // 將 'key' 轉換為 super 參數
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
      body: const Center(
          child: Text('Welcome to Teacher Page')), // 使用 'const' 關鍵字
    );
  }
}
