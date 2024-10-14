import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
          await http.get(Uri.parse('http://zct.us.kg:5000/announcement'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['announcement'] is List) {
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
            SnackBar(
              content: Text(
                'Failed to load announcements. Server error.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load announcements. Network error.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveAnnouncement({
    required String purpose,
    required String content,
    required String sender,
  }) async {
    try {
      final uri = Uri.parse('http://zct.us.kg:5000/save_announcement');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Purpose': purpose,
          'content': content,
          'sender': sender,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Announcement saved successfully.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _fetchAnnouncements();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save announcement.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save announcement. Network error.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddAnnouncementDialog() {
    TextEditingController purposeController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    String selectedSender =
        widget.role == UserRole.teacher ? 'teacher' : 'assistant';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text('新增公告'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: purposeController,
                  decoration: const InputDecoration(
                    labelText: "公告標題",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: "公告内容",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSender,
                  decoration: const InputDecoration(
                    labelText: "發送者",
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['assistant', 'teacher']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'assistant' ? '助教' : '教師'),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('保存'),
              onPressed: () {
                if (purposeController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  _saveAnnouncement(
                    purpose: purposeController.text,
                    content: contentController.text,
                    sender: selectedSender,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '請填寫所有字段',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.orange,
                    ),
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
        backgroundColor: Colors.teal,
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
              onPressed: () => _showAddAnnouncementDialog(),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : announcements.isEmpty
              ? const Center(
                  child: Text('目前沒有公告', style: TextStyle(fontSize: 18)))
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
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement['Purpose'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                announcement['content'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.teal,
                                  ),
                                ],
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
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement['Purpose'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              formattedTime,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              announcement['content'],
              style: const TextStyle(
                fontSize: 20,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
