import 'package:flutter/material.dart';

class ReviewCourseSelectionPage extends StatelessWidget {
  const ReviewCourseSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('審核選課單'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              title: const Text('選課單 1'),
              subtitle: const Text('選課單描述 1'),
              trailing: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // 審核邏輯
                },
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('選課單 2'),
              subtitle: const Text('選課單描述 2'),
              trailing: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // 審核邏輯
                },
              ),
            ),
          ),
          // 更多選課單
        ],
      ),
    );
  }
}
