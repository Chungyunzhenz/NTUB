// ignore_for_file: file_names

import 'package:flutter/material.dart';

class manualPage extends StatelessWidget {
  const manualPage({super.key});

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('使用手冊'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '如何使用应用',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Additional content...
            ],
          ),
        ),
      ),
    );
    return scaffold;
  }
}
