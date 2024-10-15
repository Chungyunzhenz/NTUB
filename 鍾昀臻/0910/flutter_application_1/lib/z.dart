import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'ReviewCoursePage.dart';
import 'manual_page.dart';
import 'z_download_page.dart';
import 'main.dart';
import 'theme_notifier.dart';
import 'announcement_page.dart' as announce;
import 'package:url_launcher/url_launcher.dart';

class AssistantPage extends StatefulWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Map<String, dynamic> user;

  const AssistantPage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.user,
  });

  @override
  _AssistantPageState createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? widget.isDarkMode;
    });
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
      throw 'Unable to open $url';
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          toggleTheme:
              context.read<ThemeNotifier>().toggleTheme, // 傳遞 toggleTheme
          isDarkMode:
              context.watch<ThemeNotifier>().isDarkMode, // 傳遞 isDarkMode
        ),
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
            color: Colors.orange[400],
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
          title: const Text('審核選課單通知'),
          onTap: () => _navigateTo(context, const ReviewCoursePage()),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('所有班級選課單歷史紀錄'),
          onTap: () => _navigateTo(context, const CourseFormViewPage()),
        ),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text('公告'),
          onTap: () => _navigateTo(
              context,
              const announce.AnnouncementPage(
                  role: announce.UserRole.assistant)),
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
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
              text: '審核選課單通知',
              page: const ReviewCoursePage(),
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context,
              icon: Icons.download,
              text: '所有班級選課單歷史紀錄',
              page: const CourseFormViewPage(),
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context,
              icon: Icons.download,
              text: '新增公告',
              page: const announce.AnnouncementPage(
                  role: announce.UserRole.assistant),
            ),
            // Add more feature cards as needed
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon, required String text, required Widget page}) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.orange.shade200,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: GestureDetector(
          onTap: () => _navigateTo(context, page),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50),
                SizedBox(height: 10),
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
