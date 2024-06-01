import 'package:flutter/material.dart';

class StudentPage extends StatelessWidget {
  final Map<String, dynamic> user;

  StudentPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
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
