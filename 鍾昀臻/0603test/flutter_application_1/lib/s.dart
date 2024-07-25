import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'form_upload_page.dart';
import 'form_download_page.dart';
import 'announcement_page.dart';
import 'manual_page.dart';
import 'historical_record.dart';
import 'stu_review.dart';
import 'login_page.dart'; // 確保正確引用 LoginPage
import 'package:url_launcher/url_launcher.dart'; // 確保導入 url_launcher

class StudentPage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Map<String, dynamic> user;

  const StudentPage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(context.watch<ThemeNotifier>().isDarkMode
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text(user['Name'],
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              accountEmail: Text(user['Role'],
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user['Name'][0],
                  style: const TextStyle(fontSize: 40.0, color: Colors.blue),
                ),
              ),
            ),
            _buildListTile(
                context, Icons.upload_file, '上傳圖片', FormUploadPage()),
            _buildListTile(
              context,
              Icons.upload_file,
              '審查進度',
              LeaveRequestPage(
                title: '審查進度', // 傳遞所需的 title 參數
                leaveDetails: {
                  // 傳遞所需的 leaveDetails 參數
                  'content': 'Sample Content',
                  'time': 'Sample Time',
                  'session': 'Sample Session',
                  'submitDate': '2024-07-01',
                  'reviewDate': '2024-07-05',
                },
              ),
            ),
            _buildListTile(context, Icons.download, '下載表單', FormDownloadPage()),
            _buildListTile(context, Icons.book, '歷史紀錄', HistoryPage()),
            _buildListTile(
                context, Icons.announcement, '公告', AnnouncementPage()),
            _buildListTile(context, Icons.book, '使用手冊', ManualPage()),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('登出'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: context.watch<ThemeNotifier>().isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: context.watch<ThemeNotifier>().isDarkMode
                    ? Colors.grey[850]!.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('姓名: ${user['Name']}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('身份: ${user['Role']}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('學制: ${user['Academic']}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('學系: ${user['Department']}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('學號: ${user['StudentID']}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildListTileCard(
                      context, Icons.upload_file, '上傳圖片', FormUploadPage()),
                  _buildListTileCard(
                      context, Icons.download, '下載表單', FormDownloadPage()),
                  _buildListTileCard(
                      context, Icons.upload_file, '審查進度', ReviewListPage()),
                  _buildListTileCard(
                      context, Icons.history, '歷史紀錄', HistoryPage()),
                  _buildListTileCard(
                      context, Icons.announcement, '公告', AnnouncementPage()),
                  _buildListTileCard(context, Icons.book, '使用手冊', ManualPage()),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchLineBot,
        child: const Icon(Icons.chat),
        backgroundColor: Colors.blue[300],
      ),
    );
  }

  ListTile _buildListTile(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
    );
  }

  Widget _buildListTileCard(
      BuildContext context, IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Card(
        color: context.watch<ThemeNotifier>().isDarkMode
            ? Colors.grey[850]!.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: ListTile(
          leading: Icon(icon,
              size: 50,
              color: context.watch<ThemeNotifier>().isDarkMode
                  ? Colors.white
                  : Colors.black),
          title: Text(title,
              style: TextStyle(
                  fontSize: 18,
                  color: context.watch<ThemeNotifier>().isDarkMode
                      ? Colors.white
                      : Colors.black)),
        ),
      ),
    );
  }

  Future<void> _launchLineBot() async {
    const url = 'https://line.me/R/ti/p/YOUR_LINE_BOT_ID';
    if (!await canLaunch(url)) {
      throw '無法打開 $url';
    }
    await launch(url);
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}

class LeaveRequestPage extends StatelessWidget {
  final String title;
  final Map<String, String> leaveDetails;

  const LeaveRequestPage({
    super.key,
    required this.title,
    required this.leaveDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
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
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow('請假內容', leaveDetails['content']),
                    _buildDetailRow('請假時間', leaveDetails['time']),
                    _buildDetailRow('學期', leaveDetails['session']),
                    _buildDetailRow('繳交時間', leaveDetails['submitDate']),
                    _buildDetailRow('審核時間', leaveDetails['reviewDate']),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('查看完畢', style: TextStyle(fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('撤回提交', style: TextStyle(fontSize: 16)),
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
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
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
