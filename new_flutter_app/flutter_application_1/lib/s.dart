import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'form_upload_page.dart';
import 'form_download_page.dart';
import 'announcement_page.dart';
import 'manual_page.dart';
import 'file_upload.dart';
import 'main.dart';

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

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('主選單',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              _buildListTile(Icons.upload_file, '上傳圖片', FormUploadPage()),
              // _buildListTile(Icons.upload_file, '上傳檔案', FileUploadPage()),
              _buildListTile(Icons.download, '下載表單', FormDownloadPage()),
              _buildListTile(Icons.announcement, '公告', AnnouncementPage()),
              _buildListTile(Icons.book, '使用手冊', ManualPage()),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('登出'),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
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
                        Text('學號: ${widget.user['StudentID']}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // 增加距離
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 30,
                  children: <Widget>[
                    _buildGridTile(Icons.upload_file, '上傳圖片', FormUploadPage()),
                    _buildGridTile(Icons.download, '下載表單', FormDownloadPage()),
                    _buildGridTile(
                        Icons.announcement, '公告', AnnouncementPage()),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
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
