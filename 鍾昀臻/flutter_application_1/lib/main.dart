// main.dart
import 'package:flutter/material.dart';
import 'AnnouncementPage.dart';
import 'FormDownloadPage.dart';
import 'FormUploadPage.dart';
//import 'manual_page.dart';
//import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文件掃描辨識',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: '文件掃描辨識'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('主菜单'),
            ),
            _createDrawerItem(
                Icons.announcement, '校園公告', const AnnouncementPage()),
            _createDrawerItem(Icons.download, '表單下載', const FormDownloadPage()),
            _createDrawerItem(
                Icons.upload_file, '表單上傳', const FormUploadPage()),
            _createDrawerItem(Icons.book, '使用手冊', const ManualPage() as Widget),
          ],
        ),
      ),
      body: const Center(
        child: Text('主页面内容'),
      ),
    );
  }

  Widget _createDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

class ManualPage {
  const ManualPage();
}
