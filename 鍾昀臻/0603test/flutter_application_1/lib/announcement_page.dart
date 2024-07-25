import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  AnnouncementPageState createState() => AnnouncementPageState();
}

class AnnouncementPageState extends State<AnnouncementPage> {
  List announcements = [];
  bool isLoading = true;
  bool isAscending = true; // 排序方式，默认为升序

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
          await http.get(Uri.parse('http://zctool.8bit.ca:5000/announcements'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            announcements = data['announcements'];
            _sortAnnouncements(); // 默认加载后排序
            isLoading = false;
          });
        }
      } else {
        // Handle server errors
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
      // Handle network errors
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
        backgroundColor: const Color.fromARGB(255, 248, 250, 250), // 设置深色蓝色背景
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
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0), // 添加边距
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
                  elevation: 4, // 设置阴影
                  margin: const EdgeInsets.only(bottom: 16.0), // 添加卡片间距
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0), // 添加内容间距
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
