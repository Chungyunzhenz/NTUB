import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'form_upload_page.dart';
import 'form_download_page.dart';
import 'announcement_page.dart';
import 'manual_page.dart';
import 'file_upload.dart';

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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? widget.isDarkMode;
    });
  }

  Future<void> _toggleTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  Future<void> _launchLineBot() async {
    const url = 'https://line.me/R/ti/p/YOUR_LINE_BOT_ID';
    if (!await canLaunch(url)) {
      throw '无法打开 $url';
    }
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.withOpacity(0.8),
                child: Column(
                  children: [
                    Text('Name: ${widget.user['Name']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Role: ${widget.user['Role']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Academic: ${widget.user['Academic']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Department: ${widget.user['Department']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text('StudentID: ${widget.user['StudentID']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            _buildGridTile(Icons.upload_file, '上傳表單', FormUploadPage()),
            _buildGridTile(Icons.download, '下載表單', FormDownloadPage()),
            _buildGridTile(Icons.announcement, '公告', AnnouncementPage()),
            _buildGridTile(Icons.book, '使用手冊', ManualPage()),
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

      ),
    );
  }

  ListTile _buildListTile(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
    );
  }

  GestureDetector _buildGridTile(IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Card(
        color: Colors.blue.shade300,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
