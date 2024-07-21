import 'package:flutter/material.dart';

class TeacherPage extends StatelessWidget {
  final Map<String, dynamic> user;

  TeacherPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Details'),
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
