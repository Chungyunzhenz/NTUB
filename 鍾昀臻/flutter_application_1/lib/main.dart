import 'package:flutter/material.dart';
import 'AnnouncementPage.dart';
import 'FormDownloadPage.dart';
import 'FormUploadPage.dart';
import 'ManualPage.dart';

void main() {
  runApp(const MyApp());
}

// 主應用程序類，配置主題和首頁路由
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文件掃描辨識',
      theme: ThemeData(
        primaryColor: Colors.blue[800], // 主色調設定為藍色
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue[800],
          secondary: Colors.blue[400],
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800], // AppBar的背景色
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue[400], // 浮動動作按鈕的背景色
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: '文件掃描辨識'),
    );
  }
}

// 主頁面類，包含狀態管理
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 主頁面的狀態類，包含UI布局
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)), // 頂部應用欄
      drawer: Drawer(
        // 導航抽屜菜單
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800], // 抽屜頭部背景色
              ),
              child: Text('主選單',
                  style:
                      TextStyle(color: Colors.white, fontSize: 24)), // 抽屜頭部文字
            ),
            _createDrawerItem(Icons.public, '校園公告', const AnnouncementPage()),
            _createDrawerItem(Icons.download, '表單下載', const FormDownloadPage()),
            _createDrawerItem(
                Icons.upload_file, '表單上傳', const FormUploadPage()),
            _createDrawerItem(Icons.book, '使用手冊', const ManualPage()),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          _buildProfileCard(context), // 個人資訊卡片
          _buildFeatureSection(context), // 功能區塊
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: '開啟 Line Bot', // 浮動動作按鈕提示
        backgroundColor: Colors.green, // 浮動動作按鈕背景色
        child: const Icon(Icons.chat), // 浮動動作按鈕圖標
      ),
    );
  }

  // 創建抽屜菜單項目
  Widget _createDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]), // 圖標顏色設定
      title: Text(title, style: TextStyle(color: Colors.black)), // 文字樣式
      onTap: () {
        Navigator.pop(context); // 關閉抽屜
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  // 建立個人資訊卡片
  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      //margin: const EdgeInsets.all
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('姓名：王小華',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)), // 姓名標示
            SizedBox(height: 10),
            Text('科系：資訊管理系'), // 科系標示
            Text('學制：日間部二技'), // 學制標示
            Text('學號：11236099'), // 學號標示
          ],
        ),
      ),
    );
  }

  // 建立功能區塊
  Widget _buildFeatureSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('主要功能',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800])), // 功能區塊標題
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // 禁止GridView滾動
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: <Widget>[
              _buildFeatureCard('校園公告', Icons.public, Colors.blue, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnnouncementPage()));
              }),
              _buildFeatureCard('表單下載', Icons.download, Colors.green, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormDownloadPage()));
              }),
              _buildFeatureCard('表單上傳', Icons.upload_file, Colors.red, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormUploadPage()));
              }),
              _buildFeatureCard('使用手冊', Icons.book, Colors.orange, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManualPage()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  // 建立功能卡片
  Widget _buildFeatureCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias, // 卡片抗鋸齒效果
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
