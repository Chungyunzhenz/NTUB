import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'user_role.dart';

enum UserRole { student, assistant, teacher }

class AnnouncementPage extends StatefulWidget {
  final UserRole role;

  const AnnouncementPage({super.key, required this.role});

  @override
  AnnouncementPageState createState() => AnnouncementPageState();
}

class AnnouncementPageState extends State<AnnouncementPage> {
  List announcements = [];
  bool isLoading = true;
  bool isAscending = true; // 排序方式，默認為升序

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_TW', null).then((_) {
      _fetchAnnouncements();
    });
  }

  Future<void> _fetchAnnouncements() async {
    try {
      // 註解掉資料庫連接的部分
      /*
      final response = await http.get(Uri.parse('http://zct.us.kg:5000/announcements'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            announcements = data['announcements'];
            _sortAnnouncements(); // 默認加載後排序
            isLoading = false;
          });
        }
      } else {
        // 處理伺服器錯誤
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load announcements. Server error.')),
          );
        }
      }
      */
      // 暫時使用假資料
      final data = {
        "announcements": [
          {
            "Purpose": "請假申請繳交時間通知",
            "content": "申請將於下週截止",
            "time": "Mon, 25 Sep 2023 10:00:00 GMT"
          },
          {
            "Purpose": "選課申請繳交時間通知",
            "content": "申請將於下週截止",
            "time": "Fri, 15 Dec 2023 12:00:00 GMT"
          }
        ]
      };
      if (mounted) {
        setState(() {
          announcements = data['announcements'] as List<dynamic>;
          _sortAnnouncements();
          isLoading = false;
        });
      }
    } catch (e) {
      // 處理網絡錯誤
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load announcements. Network error.')),
        );
      }
    }
  }

  void _showAddOrUpdateDialog({Map<String, dynamic>? announcement}) {
    TextEditingController purposeController =
        TextEditingController(text: announcement?['Purpose']);
    TextEditingController contentController =
        TextEditingController(text: announcement?['content']);
    TextEditingController timeController =
        TextEditingController(text: announcement?['time']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(announcement == null ? '新增公告' : '更新公告'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: purposeController,
                  decoration: InputDecoration(hintText: "公告標題"),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(hintText: "公告内容"),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(hintText: "公告時間"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () {
                // 这里可以调用一个函数来处理数据保存
                _saveOrUpdateAnnouncement(
                  purpose: purposeController.text,
                  content: contentController.text,
                  time: timeController.text,
                  isUpdate: announcement != null,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveOrUpdateAnnouncement(
      {required String purpose,
      required String content,
      required String time,
      bool isUpdate = false}) {
    // 这里应实现保存或更新公告的逻辑
    print("保存或更新公告: $purpose, $content, $time");
  }

  void _sortAnnouncements() {
    announcements.sort((a, b) {
      final DateFormat inputFormat =
          DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
      final DateTime timeA = inputFormat.parse(a['time']);
      final DateTime timeB = inputFormat.parse(b['time']);
      return isAscending ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
    });
  }

  void _updateAnnouncement() {
    // 模擬公告更新功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('公告已更新')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公告'),
        backgroundColor: const Color.fromARGB(255, 248, 250, 250),
        actions: [
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () {
              setState(() {
                isAscending = !isAscending;
                _sortAnnouncements();
              });
            },
          ),
          if (widget.role != UserRole.student) // 只有助教和教师可以添加或更新公告
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddOrUpdateDialog(),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                final DateFormat inputFormat =
                    DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
                final DateTime time = inputFormat.parse(announcement['time']);
                final DateFormat outputFormat =
                    DateFormat('yyyy/MM/dd HH:mm EEEE', 'zh_TW');
                final String formattedTime = outputFormat.format(time);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      announcement['Purpose'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement['content'],
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
