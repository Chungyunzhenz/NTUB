import 'package:flutter/material.dart';

class tLeaveRequestPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic> leaveDetails;

  const tLeaveRequestPage({
    Key? key,
    required this.title,
    required this.leaveDetails,
  }) : super(key: key);

  @override
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<tLeaveRequestPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildLeaveCard(Map<String, dynamic> leaveDetails) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${leaveDetails['class']} ${leaveDetails['name']} 請假單',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('請假原因: ${leaveDetails['reason']}'),
            Text('請假內容: ${leaveDetails['content']}'),
            Text('請假節次: ${leaveDetails['session']}'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle view details action
                },
                child: Text('查看'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '未審核'),
            Tab(text: '已審核'),
            Tab(text: '逾件'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '輸入對應資訊',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
          ),
          Row(
            children: [
              Checkbox(value: true, onChanged: (bool? value) {}),
              Text('班級'),
              Checkbox(value: true, onChanged: (bool? value) {}),
              Text('姓名'),
              Checkbox(value: true, onChanged: (bool? value) {}),
              Text('學號'),
              Checkbox(value: true, onChanged: (bool? value) {}),
              Text('請假原因'),
              Checkbox(value: true, onChanged: (bool? value) {}),
              Text('課程名稱'),
              Checkbox(value: true, onChanged: (bool? value) {}),
              Text('日期'),
              Checkbox(value: true, onChanged: (bool? value) {}),
              Text('節次'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  children: [
                    _buildLeaveCard({
                      'class': '二技資管一甲',
                      'name': '11236099',
                      'reason': '事假',
                      'content': 'XXXXXXXXXXXXXXXX',
                      'session': 'YYYYYYYYYYYYYY',
                    }),
                    _buildLeaveCard({
                      'class': '二技資管一甲',
                      'name': '11236088',
                      'reason': '事假',
                      'content': 'XXXXXXXXXXXXXXXX',
                      'session': 'YYYYYYYYYYYYYY',
                    }),
                  ],
                ),
                Center(child: Text('已審核')),
                Center(child: Text('逾件')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: tLeaveRequestPage(
      title: '最新消息',
      leaveDetails: {
        'content': 'Sample Content',
        'time': 'Sample Time',
        'session': 'Sample Session',
        'submitDate': '2024-07-01',
        'reviewDate': '2024-07-05',
      },
    ),
  ));
}
