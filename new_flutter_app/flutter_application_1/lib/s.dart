import 'package:flutter/material.dart';
import 'form_upload_page.dart';
import 'form_download_page.dart';
//import 'settings_page.dart';
import 'announcement_page.dart';
import 'manual_page.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Map<String, dynamic> user;

  const MyHomePage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            _createDrawerItem(
              icon: Icons.upload_file,
              text: '上傳檔案',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FormUploadPage())),
            ),
            _createDrawerItem(
              icon: Icons.download,
              text: '下載檔案',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FormDownloadPage())),
            ),
            _createDrawerItem(
              icon: Icons.announcement,
              text: '公告管理',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AnnouncementPage())),
            ),
            _createDrawerItem(
              icon: Icons.help_outline,
              text: '使用手冊',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManualPage())),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${user['Name']}'),
            Text('Role: ${user['Role']}'),
            Text('Academic: ${user['Academic']}'),
            Text('Department: ${user['Department']}'),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon), // Removed the const here
      title: Text(text),
      onTap: onTap,
    );
  }
}
