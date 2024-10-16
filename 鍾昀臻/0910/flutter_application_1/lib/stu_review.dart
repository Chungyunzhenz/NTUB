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
  List<Map<String, dynamic>> withdrawnReviews = [];
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
        Uri.parse('http://zct.us.kg:5000/getStudentReviews'),
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
              allData.where((item) => item['review_status'] == '通過').toList();
          withdrawnReviews =
              allData.where((item) => item['review_status'] == '撤回').toList();
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
      length: 4, // Increase Tab count to 4
      child: Scaffold(
        appBar: AppBar(
          title: Text('查看所有審查進度'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '審查中'),
              Tab(text: '退回'),
              Tab(text: '通過'),
              Tab(text: '撤回'),
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
                  buildReviewList(withdrawnReviews, Colors.orange[100]!),
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
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: Colors.black38,
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.teal[800],
              child: Text(
                reviews[index]['title'] != null &&
                        reviews[index]['title'].isNotEmpty
                    ? reviews[index]['title'][0]
                    : '',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              reviews[index]['title'] ?? '未知標題',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              '審核狀態: ${reviews[index]['review_status'] ?? '未知狀態'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal[800]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewDetailPage(
                    title: reviews[index]['title'] ?? '未知標題',
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
        Uri.parse('http://zct.us.kg:5000/updateReviewStatus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': review['id'], 'new_status': '撤回'}),
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
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                          '請假內容', reviewDetails['description'] ?? '無描述'),
                      _buildDetailRow(
                          '提交時間', reviewDetails['submission_date'] ?? '無提交時間'),
                      _buildDetailRow(
                          '審核時間', reviewDetails['review_date'] ?? '無審核時間'),
                      _buildDetailRow(
                          '審核狀態', reviewDetails['review_status'] ?? '未知狀態'),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close),
                            label: Text('關閉',
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          // 只有當審核狀態為「審查中」時顯示撤回按鈕
                          if (reviewDetails['review_status'] == '審查中')
                            ElevatedButton.icon(
                              onPressed: () {
                                onWithdraw();
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.undo),
                              label: Text('撤回審核',
                                  style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
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
