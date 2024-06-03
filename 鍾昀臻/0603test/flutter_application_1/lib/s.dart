import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_upload_page.dart';
import 'form_download_page.dart';
import 'announcement_page.dart';
import 'manual_page.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

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
    const url = 'https://line.me/R/ti/p/YOUR_LINE_BOT_ID'; // 替換成你的Line Bot的URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '無法打開 $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        textTheme: TextTheme(
            //bodyText1: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            //bodyText2: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            // 在這裡添加更多的文本樣式，根據需要調整顏色
            ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('學生介面'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => _toggleTheme(),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
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
                title: const Text('上傳表單'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormUploadPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('下載表單'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormDownloadPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.announcement),
                title: const Text('公告'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnnouncementPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('使用手冊'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManualPage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'), // 添加背景圖片
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.blue.withOpacity(0.8),
                  child: const Text(
                    '資料庫內容顯示區',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FormUploadPage()),
                          );
                        },
                        child: Card(
                          color: Colors.blue.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.upload_file, size: 50),
                                SizedBox(height: 10),
                                Text('上傳表單', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FormDownloadPage()),
                          );
                        },
                        child: Card(
                          color: Colors.blue.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.download, size: 50),
                                SizedBox(height: 10),
                                Text('下載表單', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AnnouncementPage()),
                          );
                        },
                        child: Card(
                          color: Colors.blue.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.announcement, size: 50),
                                SizedBox(height: 10),
                                Text('公告', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ManualPage()),
                          );
                        },
                        child: Card(
                          color: Colors.blue.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.book, size: 50),
                                SizedBox(height: 10),
                                Text('使用手冊', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _launchLineBot,
          child: const Icon(Icons.chat),
          backgroundColor: Color.fromARGB(255, 141, 193, 225),
        ),
      ),
    );
  }
}
