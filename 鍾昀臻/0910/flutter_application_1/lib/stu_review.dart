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

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.166:5002/getStudentReviews'),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> allData = List<Map<String, dynamic>>.from(
          json.decode(response.body),
        );

        setState(() {
          reviewingReviews =
              allData.where((item) => item['review_status'] == '審查中').toList();
          rejectedReviews =
              allData.where((item) => item['review_status'] == '退回').toList();
          completedReviews =
              allData.where((item) => item['review_status'] == '完成').toList();
          isLoading = false; // Loading complete
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            'Error fetching data: ${response.statusCode} - ${response.reasonPhrase}');
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
      length: 3, // Increase Tab count to 3
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
                    onWithdraw: () => _handleWithdraw(reviews[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleWithdraw(Map<String, dynamic> review) async {
    try {
      final response = await http.post(
        Uri.parse('http://zct.us.kg:5000/withdrawReview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'review_id': review['id']}),
      );

      if (response.statusCode == 200) {
        // 撤回成功後，重新獲取數據更新 UI
        await fetchReviews();
        print('Review withdrawn successfully');
      } else {
        print('Failed to withdraw review: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught while withdrawing review: $e');
    }
  }
}

class ReviewDetailPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> reviewDetails;
  final VoidCallback onWithdraw;

  const ReviewDetailPage({
    Key? key,
    required this.title,
    required this.reviewDetails,
    required this.onWithdraw,
  }) : super(key: key);

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
                            icon: Icon(Icons.close),
                            label: Text('關閉'),
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
                              onWithdraw();
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.undo),
                            label: Text('撤回審核'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[400],
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
