import 'package:flutter/material.dart';

class AssistantPage extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final String title;

  const AssistantPage({
    super.key,
    required this.user,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${user['Name']}'),
            Text('Role: ${user['Role']}'),
            Text('Academic: ${user['Academic']}'),
            Text('Department: ${user['Department']}'),
          ],
        ),
      ),
    );
  }
}
