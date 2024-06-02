import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Map<String, dynamic> user;

  const MyHomePage({
    Key? key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.user,
  }) : super(key: key);

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
