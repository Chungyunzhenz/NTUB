import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  bool isAscending = true;

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
          await http.get(Uri.parse('http://192.168.0.166:5001/announcement'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['announcement'] is List) {
          // 修正這裡，應該是 'announcement'
          setState(() {
            announcements =
                List<Map<String, dynamic>>.from(data['announcement']);
            _sortAnnouncements();
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

  Future<void> _saveAnnouncement({
    required String purpose,
    required String content,
    required String sender, // 傳遞 sender
  }) async {
    try {
      final uri = Uri.parse('http://192.168.0.166:5001/save_announcement');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Purpose': purpose, // 修正這裡，確保字段名稱與後端一致
          'content': content,
          'sender': sender,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement saved successfully.')),
        );
        _fetchAnnouncements(); // 重新加載公告
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save announcement.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save announcement. Network error.')),
      );
    }
  }

  void _showAddAnnouncementDialog() {
    TextEditingController purposeController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    // 預設 sender 根據當前角色決定，僅允許助教和教師選擇
    String selectedSender =
        widget.role == UserRole.teacher ? 'teacher' : 'assistant';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增公告'),
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
                const SizedBox(height: 16),
                // 發送者選擇下拉選單，只能選擇助教或教師
                DropdownButton<String>(
                  value: selectedSender,
                  items: <String>['assistant', 'teacher']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSender = newValue!;
                    });
                  },
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
                if (purposeController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  _saveAnnouncement(
                    purpose: purposeController.text,
                    content: contentController.text,
                    sender: selectedSender, // 傳遞選擇的 sender
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請填寫所有字段')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _sortAnnouncements() {
    announcements.sort((a, b) {
      final DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final DateTime timeA = inputFormat.parse(a['time']);
      final DateTime timeB = inputFormat.parse(b['time']);
      return isAscending ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
    });
  }

  void _navigateToDetailPage(Map<String, dynamic> announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnnouncementDetailPage(announcement: announcement),
      ),
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
          if (widget.role != UserRole.student) // 只有助教和教師可以添加公告
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddAnnouncementDialog(),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : announcements.isEmpty
              ? const Center(child: Text('目前沒有公告'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    final DateFormat inputFormat =
                        DateFormat('yyyy-MM-dd HH:mm:ss');
                    final DateTime time =
                        inputFormat.parse(announcement['time']);
                    final DateFormat outputFormat =
                        DateFormat('yyyy/MM/dd HH:mm EEEE', 'zh_TW');
                    final String formattedTime = outputFormat.format(time);

                    return GestureDetector(
                      onTap: () => _navigateToDetailPage(announcement),
                      child: Card(
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
                      ),
                    );
                  },
                ),
    );
  }
}

class AnnouncementDetailPage extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetailPage({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final DateTime time = inputFormat.parse(announcement['time']);
    final DateFormat outputFormat =
        DateFormat('yyyy/MM/dd HH:mm EEEE', 'zh_TW');
    final String formattedTime = outputFormat.format(time);

    return Scaffold(
      appBar: AppBar(
        title: const Text('公告詳情'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement['Purpose'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              formattedTime,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              announcement['content'],
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
