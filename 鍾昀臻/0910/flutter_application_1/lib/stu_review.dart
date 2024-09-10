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
  List<Map<String, dynamic>> completedReviews = [];
  bool isLoading = true;

  //final String serverIp = '192.168.0.166';
  final String serverIp = '172.20.10.3';
  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() {
      isLoading = true; // 开始加载时设置为true
    });

    try {
      final responseLeave = await http.get(
        Uri.parse('http://localhost:4000/getLeaveRequests?title=請假單'),
      );

      final responseCourse = await http.get(
        Uri.parse('http://localhost:4000/getLeaveRequests?title=選課單'),
      );

      if (responseLeave.statusCode == 200 && responseCourse.statusCode == 200) {
        List<Map<String, dynamic>> leaveData = List<Map<String, dynamic>>.from(
          json.decode(responseLeave.body),
        );
        List<Map<String, dynamic>> courseData = List<Map<String, dynamic>>.from(
          json.decode(responseCourse.body),
        );

        // 打印获取到的假单和选课单数据
        print('Leave Data: $leaveData');
        print('Course Data: $courseData');

        List<Map<String, dynamic>> allData = leaveData + courseData;

        setState(() {
          reviewingReviews =
              allData.where((item) => item['review_status'] == '審查中').toList();
          rejectedReviews =
              allData.where((item) => item['review_status'] == '退回').toList();
          completedReviews =
              allData.where((item) => item['review_status'] == '完成').toList();

          // 打印分类后的数据
          print('Reviewing Reviews: $reviewingReviews');
          print('Rejected Reviews: $rejectedReviews');
          print('Completed Reviews: $completedReviews');

          isLoading = false; // 加载完成时设置为false
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            'Error fetching data: ${responseLeave.statusCode} - ${responseLeave.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Exception caught: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 将 Tab 数量增加到3
      child: Scaffold(
        appBar: AppBar(
          title: Text('查看所有審查進度'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '審查中'),
              Tab(text: '退回'),
              Tab(text: '完成'),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  buildReviewList(reviewingReviews, Colors.teal[100]!),
                  buildReviewList(rejectedReviews, Colors.red[100]!),
                  buildReviewList(completedReviews, Colors.green[100]!),
                ],
              ),
      ),
    );
  }

  Widget buildReviewList(List<Map<String, dynamic>> reviews, Color color) {
    // 打印当前Tab显示的数据
    print('Building review list for: ${reviews.length} items.');

    if (reviews.isEmpty) {
      return Center(
        child: Text(
          '沒有項目',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return Card(
          color: color,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
          shadowColor: Colors.black54,
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
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewDetailPage(
                    title: reviews[index]['title'],
                    reviewDetails: reviews[index],
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

class ReviewDetailPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> reviewDetails;

  const ReviewDetailPage({
    super.key,
    required this.title,
    required this.reviewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // 打印详细页面的数据
    print('Review Details for $title: $reviewDetails');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
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
                      _buildDetailRow('請假內容', reviewDetails['description']),
                      _buildDetailRow('提交時間', reviewDetails['submission_date']),
                      _buildDetailRow('審核時間', reviewDetails['review_date']),
                      _buildDetailRow('審核狀態', reviewDetails['review_status']),
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
                              // 添加撤回提交的邏輯
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
