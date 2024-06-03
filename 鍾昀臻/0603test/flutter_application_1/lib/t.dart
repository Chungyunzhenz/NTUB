import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ReviewLeavePage.dart';
import 'manual_page.dart';
import 'form_download_page.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
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
    const url = 'https://line.me/R/ti/p/YOUR_LINE_BOT_ID';
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
        primarySwatch: Colors.green,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('教師介面'),
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
          backgroundColor: Colors.green[800],
        ),
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
          title: const Text('審核假單'),
          onTap: () => _navigateTo(context, const ReviewLeavePage()),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('查看班級檔案'),
          onTap: () => _navigateTo(context, const FormDownloadPage()),
        ),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text('使用手冊'),
          onTap: () => _navigateTo(context, const ManualPage()),
        ),
      ],
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
              text: '審核請假單',
              page: const ReviewLeavePage(),
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
          color: Colors.green.shade200,
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
