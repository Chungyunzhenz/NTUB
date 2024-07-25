import 'package:flutter/material.dart';

class ReviewListPage extends StatelessWidget {
  final List<Map<String, String>> reviews = [
    {
      'title': '2024-06-28 請假單',
      'content': '請假內容 xxxxxxxxxxxx',
      'time': '2024-07-01 至 2024-07-05',
      'session': '星期一二節',
      'submitDate': '2024-07-01',
      'reviewDate': '2024-07-05',
    },
    {
      'title': '2024-06-28 選課單',
      'content': '課程內容 1',
      'time': '2024-07-01 至 2024-07-05',
      'period': '第一學期',
      'submitDate': '2024-07-01',
      'reviewDate': '2024-07-05',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('查看所有審查進度'),
          bottom: TabBar(
            tabs: [
              Tab(text: '審核通過'),
              Tab(text: '審核未過'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('A'),
                  ),
                  title: Text(reviews[index]['title']!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaveRequestPage(
                          title: reviews[index]['title']!,
                          courseDetails: reviews[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Center(child: Text('沒有審核未過的項目')),
          ],
        ),
      ),
    );
  }
}

class LeaveRequestPage extends StatelessWidget {
  final String title;
  final Map<String, String> courseDetails;

  const LeaveRequestPage({
    super.key,
    required this.title,
    required this.courseDetails,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow('請假內容', courseDetails['content']),
                    _buildDetailRow('請假時間', courseDetails['time']),
                    _buildDetailRow('請假節數', courseDetails['session']),
                    _buildDetailRow('繳交時間', courseDetails['submitDate']),
                    _buildDetailRow('審核時間', courseDetails['reviewDate']),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('查看完畢', style: TextStyle(fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('撤回提交', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ReviewListPage(),
  ));
}
