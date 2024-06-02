import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'announcement_page.dart';
import 'form_upload_page.dart';
import 'form_download_page.dart';
import 'manual_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Portal',
      theme: ThemeData.light().copyWith(
        primaryColor: Color.fromARGB(255, 216, 224, 146),
        appBarTheme:
            const AppBarTheme(color: Color.fromARGB(255, 227, 208, 60)),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Color.fromARGB(255, 245, 238, 180),
        appBarTheme:
            const AppBarTheme(color: Color.fromARGB(255, 219, 239, 129)),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Teacherpage(
        title: '歡迎進入教師畫面',
        toggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class Teacherpage extends StatefulWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const Teacherpage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<Teacherpage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<Teacherpage> {
  String userName = '王小華';
  String userNumber = '12345678';
  String userProgram = '資訊管理系';

  void _updateUserName(String newUserName) {
    setState(() {
      userName = newUserName;
    });
  }

  void _updateUserNumber(String newUserNumber) {
    setState(() {
      userNumber = newUserNumber;
    });
  }

  void _updateUserProgram(String newUserProgram) {
    setState(() {
      userProgram = newUserProgram;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '主選單',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('首頁'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.announcement),
              title: const Text('公告管理'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnnouncementPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file), // 修改: 更改頁面名稱
              title: const Text('上傳'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const FormTypeSelectionPage()), // 修改: 使用新的上傳頁面
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download), // 修改: 更改頁面名稱
              title: const Text('下載'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const FormDownloadPage()), // 修改: 使用新的下載頁面
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book), // 修改: 更改頁面名稱
              title: const Text('使用手冊'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ManualPage()), // 修改: 使用新的使用手冊頁面
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings), // 修改: 更改頁面名稱
              title: const Text('設定'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      updateUserName: _updateUserName,
                      updateUserNumber: _updateUserNumber,
                      updateUserProgram: _updateUserProgram,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              color: Colors.white.withOpacity(0.8),
              child: const ListTile(
                leading:
                    Icon(Icons.account_circle, size: 50, color: Colors.blue),
                title: Text('姓名: 張三'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('學號: 12345678'),
                    Text('科系: 資訊管理系'),
                    Text('學制: 大學部'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: <Widget>[
                  _buildFeatureCard(
                    context,
                    Icons.announcement,
                    '公告管理',
                    const AnnouncementPage(),
                    Colors.orange,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.upload_file,
                    '上傳',
                    const FormTypeSelectionPage(), // 修改: 使用新的上傳頁面
                    Colors.green,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.download,
                    '下載',
                    const FormDownloadPage(), // 修改: 使用新的下載頁面
                    Colors.purple,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.book,
                    '使用手冊',
                    const ManualPage(), // 修改: 使用新的使用手冊頁面
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LineBotPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title,
      Widget page, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.5), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class LineBotPage extends StatelessWidget {
  const LineBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Line Bot'),
      ),
      body: const Center(
        child: Text('這是 Line Bot 頁面'),
      ),
    );
  }
}
