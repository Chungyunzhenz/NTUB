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
          _buildCourseSelectionCard(context, '選課單 1', '選課單描述 1', {
            'date': '2024-06-28',
            'content': '課程內容 1',
            'time': '2024-07-01 至 2024-07-05',
            'period': '第一學期',
            'submitDate': '2024-07-01',
            'reviewDate': '2024-07-05',
          }),
          _buildCourseSelectionCard(context, '選課單 2', '選課單描述 2', {
            'date': '2024-07-01',
            'content': '課程內容 2',
            'time': '2024-08-01 至 2024-08-05',
            'period': '第二學期',
            'submitDate': '2024-07-02',
            'reviewDate': '2024-07-06',
          }),
          // 更多選課單
        ],
      ),
    );
  }

  Widget _buildCourseSelectionCard(BuildContext context, String title,
      String subtitle, Map<String, String> details) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('${details['date']}選課單'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('課程內容: ${details['content']}'),
                    Text('選課時間: ${details['time']}'),
                    Text('學期: ${details['period']}'),
                    Text('繳交時間: ${details['submitDate']}'),
                    Text('審核時間: ${details['reviewDate']}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 審核通過邏輯
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      color: Colors.black,
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '審核通過',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // 返回審核邏輯
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '返回審核',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
