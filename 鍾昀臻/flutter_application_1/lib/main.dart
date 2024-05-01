import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文件掃描辨識',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '文件掃描辨識'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var listView = ListView(
      padding: EdgeInsets.zero, // Ensure padding is set to zero for header
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child:
              Text('主選單', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        _createDrawerItem(Icons.public, '校園公告', const AnnouncementPage()),
        _createDrawerItem(Icons.download, '表單下載', const FormDownloadPage()),
        _createDrawerItem(Icons.upload_file, '表單上傳', const FormUploadPage()),
        _createDrawerItem(
            Icons.book, '使用手冊', const ManualPage()), // Correct casting
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: listView,
      ),
      body: Center(child: Text('主畫面内容')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // 这里可以添加打开Line Bot的逻辑
        tooltip: '開啟 Line Bot',
        backgroundColor: Colors.green,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _createDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white), // 使用参数传入的图标
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // 关闭抽屉
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ); // 导航到对应页面
      },
    );
  }
}

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('校園公告'),
      ),
      body: Center(
        child: Text('校園公告页面'),
      ),
    );
  }
}

class FormDownloadPage extends StatelessWidget {
  const FormDownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('表單下載'),
      ),
      body: Center(
        child: Text('表單下載页面'),
      ),
    );
  }
}

class FormUploadPage extends StatelessWidget {
  const FormUploadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('表單上傳'),
      ),
      body: Center(
        child: Text('表單上傳页面'),
      ),
    );
  }
}

class ManualPage extends StatelessWidget {
  const ManualPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('使用手冊'),
      ),
      body: Center(
        child: Text('使用手冊页面'),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 登录逻辑
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
