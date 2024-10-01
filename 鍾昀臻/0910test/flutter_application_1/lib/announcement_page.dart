import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

enum UserRole {
  student,
  assistant,
  teacher,
}

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
      final response =
          await http.get(Uri.parse('http://zct.us.kg:5000/announcements'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to load announcements. Server error.')),
          );
        }
      }
    } catch (e) {
      print('Error fetching announcements: $e');
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

  Future<void> _saveAnnouncement(String purpose, String content, String time,
      {bool isUpdate = false, String? id}) async {
    final url = isUpdate
        ? 'http://zct.us.kg:5000/announcements/$id'
        : 'http://zct.us.kg:5000/announcements';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Purpose': purpose,
        'content': content,
        'time': time,
      }),
    );

    if (response.statusCode == 200) {
      // 成功新增或更新後刷新公告列表
      _fetchAnnouncements();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('公告已成功保存')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存公告失敗')),
      );
    }
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
          if (widget.role != UserRole.student)
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
                    trailing: widget.role != UserRole.student
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddOrUpdateDialog(
                                announcement: announcement),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }

  void _showAddOrUpdateDialog({Map<String, dynamic>? announcement}) {
    TextEditingController purposeController =
        TextEditingController(text: announcement?['Purpose']);
    TextEditingController contentController =
        TextEditingController(text: announcement?['content']);
    TextEditingController timeController = TextEditingController(
        text: announcement?['time'] ??
            DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz').format(DateTime.now()));

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
                  decoration: const InputDecoration(hintText: "公告標題"),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(hintText: "公告内容"),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(hintText: "公告時間"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('保存'),
              onPressed: () {
                _saveAnnouncement(
                  purposeController.text,
                  contentController.text,
                  timeController.text,
                  isUpdate: announcement != null,
                  id: announcement?['id'],
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
