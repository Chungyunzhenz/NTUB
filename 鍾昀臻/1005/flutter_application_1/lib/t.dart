import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'ReviewLeavePage.dart';
import 'manual_page.dart';
import 't_download_page.dart';
import 'login_page.dart';
import 'theme_notifier.dart';
import 'announcement_page.dart' as announce;
import 'user_role.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherPage extends StatefulWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Map<String, dynamic> user;

  const TeacherPage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.user,
  });

  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  late bool isDarkMode;
  int notificationCount = 3; // 新增通知數量

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  Future<void> _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
      widget.toggleTheme();
    });
  }

  Future<void> _launchLineBot() async {
    const url = 'https://line.me/R/ti/p/YOUR_LINE_BOT_ID';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '無法打開 $url';
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: _buildDrawer(),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchLineBot,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.green[400],
          ),
          child: const Text(
            '主選單',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: const Text('審核假單通知'),
          onTap: () => _navigateTo(context, const ReviewLeavePage()),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('所有班級請假單歷史紀錄'),
          onTap: () => _navigateTo(context, const FormDownloadPage()),
        ),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text('使用手冊'),
          onTap: () => _navigateTo(context, const ManualPage()),
        ),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text('新增公告'),
          onTap: () => _navigateTo(context,
              const announce.AnnouncementPage(role: announce.UserRole.teacher)),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('登出'),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: isDarkMode ? Colors.black12 : Colors.green.shade50,
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.green.shade200, // 改為綠色色調
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('姓名: ${widget.user['Name']}',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18)),
                      Text('身份: ${widget.user['Role']}',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18)),
                      Text('學制: ${widget.user['Academic']}',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18)),
                      Text('學系: ${widget.user['Department']}',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context,
              icon: Icons.upload_file,
              text: '審核請假單通知',
              page: const ReviewLeavePage(),
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context,
              icon: Icons.download,
              text: '所有班級請假單歷史紀錄',
              page: const FormDownloadPage(),
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context,
              icon: Icons.download,
              text: '新增公告',
              page: const announce.AnnouncementPage(
                  role: announce.UserRole.teacher),
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context,
              icon: Icons.book,
              text: '使用手冊',
              page: const ManualPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required String text,
      required Widget page,
      int notificationCount = 0}) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          color: Colors.green.shade200, // 綠色色調
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: GestureDetector(
          onTap: () => _navigateTo(context, page),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 20),
                Stack(
                  children: [
                    Icon(icon, size: 50),
                    if (notificationCount > 0)
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 10,
                          child: Text(
                            '$notificationCount',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 20),
                Text(text, style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
