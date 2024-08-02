import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewListPage extends StatefulWidget {
  @override
  _ReviewListPageState createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  List<Map<String, dynamic>> reviewingReviews = [];
  List<Map<String, dynamic>> rejectedReviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:4000/review_progress'),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
          json.decode(response.body),
        );

        // 根據 review_status 分配數據
        setState(() {
          reviewingReviews =
              data.where((item) => item['review_status'] == '審核中').toList();
          rejectedReviews =
              data.where((item) => item['review_status'] == '被退回').toList();
        });
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('查看所有審查進度'),
          bottom: TabBar(
            tabs: [
              Tab(text: '審核中'),
              Tab(text: '被退回'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildReviewList(reviewingReviews),
            buildReviewList(rejectedReviews),
          ],
        ),
      ),
    );
  }

  Widget buildReviewList(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) {
      return Center(child: Text('沒有項目'));
    }

    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                reviews[index]['title'][0],
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              reviews[index]['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text('審核狀態: ${reviews[index]['review_status']}'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaveRequestPage(
                    title: reviews[index]['title'],
                    courseDetails: reviews[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class LeaveRequestPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> courseDetails;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('請假內容', courseDetails['description']),
                      _buildDetailRow('提交時間', courseDetails['submission_date']),
                      _buildDetailRow('審核時間', courseDetails['review_date']),
                      _buildDetailRow('審核狀態', courseDetails['review_status']),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.check),
                            label: Text('返回'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // 在這裡添加撤回提交的邏輯
                            },
                            icon: Icon(Icons.undo),
                            label: Text('撤回提交'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    theme: ThemeData(
      primaryColor: Colors.teal,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    ),
  ));
}
