import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // 引入 intl 的本地化資料

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  AnnouncementPageState createState() => AnnouncementPageState();
}

class AnnouncementPageState extends State<AnnouncementPage> {
  List announcements = [];
  bool isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                final DateFormat inputFormat =
                    DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
                final DateTime time = inputFormat.parse(announcement['time']);
                final DateFormat outputFormat =
                    DateFormat('yyyy/MM/dd HH:mm EEEE', 'zh_TW');
                final String formattedTime = outputFormat.format(time);

                return ListTile(
                  title: Text(announcement['Purpose']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement['content']),
                      SizedBox(height: 5), // 增加一些空隙
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.grey, // 可選：更改顏色使時間顯示更明顯
                          fontSize: 12, // 可選：調整字體大小
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
