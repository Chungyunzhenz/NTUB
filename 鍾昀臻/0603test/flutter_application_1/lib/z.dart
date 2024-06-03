import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ReviewCourseSelectionPage.dart';
import 'announcement_page.dart';
import 'manual_page.dart';
import 'form_download_page.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

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

  _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  _launchLineBot() async {
    const url =
        'https://line.me/R/ti/p/YOUR_LINE_BOT_ID'; // Replace with your Line Bot URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Unable to open $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('助教介面'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _buildBody(context),
        floatingActionButton: FloatingActionButton(
          onPressed: _launchLineBot,
          child: const Icon(Icons.chat),
          backgroundColor:
              Colors.orange[800], // Adjusted to match the theme color
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        // Adjust the opacity here using withOpacity method
        color: Color.fromARGB(255, 238, 160, 82)!
            .withOpacity(0.85), // Setting opacity to 85%
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 242, 240, 238)!
                    .withOpacity(0.85), // Also set the same opacity for header
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
              title: const Text('審核選課單'),
              onTap: () =>
                  _navigateTo(context, const ReviewCourseSelectionPage()),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('查看班級檔案'),
              onTap: () => _navigateTo(context, const FormDownloadPage()),
            ),
            ListTile(
              leading: const Icon(Icons.announcement),
              title: const Text('公告'),
              onTap: () => _navigateTo(context, const AnnouncementPage()),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('使用手冊'),
              onTap: () => _navigateTo(context, const ManualPage()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFeatureCard(
              context,
              icon: Icons.upload_file,
              text: '審核選課單',
              page: const ReviewCourseSelectionPage(),
            ),
            _buildFeatureCard(
              context,
              icon: Icons.download,
              text: '查看班級檔案',
              page: const FormDownloadPage(),
            ),
            // Add more feature cards as needed
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon, required String text, required Widget page}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateTo(context, page),
        child: Container(
          color: Colors.orange.shade200,
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
