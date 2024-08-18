import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewLeavePage extends StatefulWidget {
  const ReviewLeavePage({super.key});

  @override
  _ReviewLeavePageState createState() => _ReviewLeavePageState();
}

class _ReviewLeavePageState extends State<ReviewLeavePage> {
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _returnedRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];
  bool _isLoading = true;

  final String serverIp = '172.20.10.3';

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  Future<void> _fetchLeaveRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pendingResponse = await http.get(
        Uri.parse(
            'http://$serverIp:3000/getLeaveRequests?status=審查中&title=請假單'),
      );
      final returnedResponse = await http.get(
        Uri.parse('http://$serverIp:3000/getLeaveRequests?status=退回&title=請假單'),
      );
      final completedResponse = await http.get(
        Uri.parse('http://$serverIp:3000/getLeaveRequests?status=完成&title=請假單'),
      );

      // Debug output
      print('Pending Response: ${pendingResponse.body}');
      print('Returned Response: ${returnedResponse.body}');
      print('Completed Response: ${completedResponse.body}');

      if (pendingResponse.statusCode == 200 &&
          returnedResponse.statusCode == 200 &&
          completedResponse.statusCode == 200) {
        setState(() {
          _pendingRequests = List<Map<String, dynamic>>.from(
            json.decode(pendingResponse.body),
          );
          _returnedRequests = List<Map<String, dynamic>>.from(
            json.decode(returnedResponse.body),
          );
          _completedRequests = List<Map<String, dynamic>>.from(
            json.decode(completedResponse.body),
          );
          _isLoading = false;
        });
      } else {
        throw Exception('加载请假单失败');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('错误: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateReviewStatus(int id, String status,
      {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:3000/updateReviewStatus'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'status': status,
          'return_reason': reason,
          'returned_by': 'teacher',
        }),
      );

      if (response.statusCode == 200) {
        await _fetchLeaveRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('請假單已更新為 $status'),
            backgroundColor: status == '通過' ? Colors.green : Colors.red,
          ),
        );
      } else {
        throw Exception('更新審核狀態失敗');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('錯誤: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showReturnDialog(int id) async {
    String reason = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('請輸入退回原因'),
          content: TextField(
            onChanged: (value) {
              reason = value;
            },
            decoration: const InputDecoration(hintText: "退回原因"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateReviewStatus(id, '退回', reason: reason);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child:
                    const Text('確定退回', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('查看請假單進度'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: '審查中'),
              Tab(text: '退回'),
              Tab(text: '已完成'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTabContent(_pendingRequests, '審查中'),
                  _buildTabContent(_returnedRequests, '退回'),
                  _buildTabContent(_completedRequests, '已完成'),
                ],
              ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> requests, String status) {
    if (requests.isEmpty) {
      return const Center(child: Text('沒有請假單'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildCourseSelectionCard(
          context,
          request['title'],
          request['description'],
          request,
          status,
        );
      },
    );
  }

  Widget _buildCourseSelectionCard(BuildContext context, String title,
      String subtitle, Map<String, dynamic> details, String status) {
    final theme = Theme.of(context);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      color: Colors.green.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54)),
        trailing: Icon(Icons.arrow_forward_ios,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${details['submission_date']} 請假單',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('課程名稱: ${details['course_name']}'),
                    Text('選課時間: ${details['period']}'),
                    Text('學期: ${details['academic_year']}'),
                    Text('請假理由: ${details['leave_reason']}'),
                    Text('申請日期: ${details['submission_date']}'),
                    Text('審核狀態: ${details['review_status']}'),
                    if (status == '退回' && details.containsKey('return_reason'))
                      Text('退回原因: ${details['return_reason']}'),
                  ],
                ),
                actions: status == '審查中'
                    ? [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _updateReviewStatus(details['id'], '通過');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: const Text('審核通過',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _showReturnDialog(details['id']);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: const Text('返回審核',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ]
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
