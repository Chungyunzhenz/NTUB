import 'package:flutter/material.dart';

class TeacherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Page'),
      ),
      body: Center(
        child: Text('Welcome, Teacher!'),
      ),
    );
  }
}
