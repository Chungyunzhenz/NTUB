import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AnnouncementPage.dart';
import 'FormDownloadPage.dart';

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
        colorScheme: ColorScheme.light(
          primary: Colors.lightBlueAccent,
          onPrimary: Colors.white,
          secondary: Colors.lightBlue.shade100,
          onSecondary: Colors.black,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.lightBlue.shade50,
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
  void openLineBot() {
    // 這裡添加打開 Line Bot 的操作
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                '主菜單',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 24,
                ),
              ),
            ),
            // 使用 Material Design 指南中推荐的 ListTile，为每个功能添加适当的图标
            _buildDrawerItem(Icons.announcement, '校園公告', AnnouncementPage()),
            _buildDrawerItem(Icons.download, '表單下載', FormDownloadPage()),
            _buildDrawerItem(Icons.upload_file, '表單上傳', null), // 暂无页面，传递null
            _buildDrawerItem(Icons.book, '使用手冊', null), // 暂无页面，传递null
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          _buildProfileCard(context),
          // 可以添加其他功能按钮或信息显示
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openLineBot,
        tooltip: '開啟 Line Bot',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        }
      },
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  AssetImage('assets/profile_pic.jpg'), // 使用本地圖片為圖像
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('姓名：王小華', style: Theme.of(context).textTheme.bodyText1),
                  Text('科系：資訊管理系',
                      style: Theme.of(context).textTheme.bodyText1),
                  Text('學制：日間部二技',
                      style: Theme.of(context).textTheme.bodyText1),
                  Text('學號：11236099',
                      style: Theme.of(context).textTheme.bodyText1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
