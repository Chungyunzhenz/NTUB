import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'form_upload_page.dart';
import 'announcement_page.dart';
import 'manual_page.dart';
import 'historical_record.dart';
import 'stu_review.dart';
import 'login_page.dart'; // 確保正確引用 LoginPage
import 'package:url_launcher/url_launcher.dart'; // 確保導入 url_launcher

class StudentPage extends StatefulWidget {
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
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  late String selectedProfileImage;

  @override
  void initState() {
    super.initState();
    selectedProfileImage =
        widget.user['ProfileImage'] ?? 'assets/a.png'; // Default profile image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                color: Colors.teal,
              ),
              accountName: Text(widget.user['Name'] ?? '未提供姓名',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              accountEmail: Text(widget.user['Role'] ?? '未提供角色',
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              currentAccountPicture: GestureDetector(
                onTap: () => _showProfileImageDialog(context),
                child: CircleAvatar(
                  backgroundImage: AssetImage(selectedProfileImage),
                ),
              ),
            ),
            _buildListTile(
                context, Icons.upload_file, '上傳圖片', FormUploadPage()),
            _buildListTile(
                context, Icons.verified_user, '審查進度', ReviewListPage()),
            _buildListTile(context, Icons.history, '歷史紀錄', HistoryPage()),
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
                : [Colors.teal, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: context.watch<ThemeNotifier>().isDarkMode
                      ? Colors.grey[850]!.withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: SingleChildScrollView(
                  // 使用 SingleChildScrollView 來避免溢出
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('姓名: ${widget.user['Name'] ?? '未提供姓名'}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('身份: ${widget.user['Role'] ?? '未提供身份'}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('學制: ${widget.user['Academic'] ?? '未提供學制'}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('學系: ${widget.user['Department'] ?? '未提供學系'}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                      Text('學號: ${widget.user['StudentID'] ?? '未提供學號'}',
                          style: TextStyle(
                              color: context.watch<ThemeNotifier>().isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              flex: 2,
              child: ListView(
                children: <Widget>[
                  _buildListTileCard(
                      context, Icons.upload_file, '上傳圖片', FormUploadPage()),
                  _buildListTileCard(
                      context, Icons.verified_user, '審查進度', ReviewListPage()),
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
        backgroundColor: Colors.teal[300],
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

  void _showProfileImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('選擇頭貼'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileImageOption('lib/assets/a.jpg'),
                _buildProfileImageOption('lib/assets/b.jpg'),
                _buildProfileImageOption('lib/assets/c.jpg'),
                _buildProfileImageOption('lib/assets/d.jpg'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImageOption(String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProfileImage = imagePath;
        });
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(imagePath),
        ),
      ),
    );
  }
}
