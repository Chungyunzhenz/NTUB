import 'package:flutter/material.dart';

class ReviewLeavePage extends StatelessWidget {
  const ReviewLeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('審核請假單'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              title: const Text('請假單 1'),
              subtitle: const Text('請假單描述 1'),
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
              title: const Text('請假單 2'),
              subtitle: const Text('請假單描述 2'),
              trailing: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // 審核邏輯
                },
              ),
            ),
          ),
          // 更多請假單
        ],
      ),
    );
  }
}
