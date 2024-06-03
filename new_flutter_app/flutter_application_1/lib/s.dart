
import 'package:flutter/material.dart';
import 'package:flutter_application_1/form_download_page.dart';
import 'announcement_page.dart';
import 'file_upload.dart';
import 'form_upload_page.dart';

class StudentPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            Text('StudentID: ${user['StudentID']}'),
          SizedBox(height: 20), // 添加間距
            ElevatedButton(
              onPressed: () {
                // 當按鈕被點擊時，導航到 TargetPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormDownloadPage()),
                );
              },
              child: Text('Go to download Page'), // 按鈕文本
            ),
            SizedBox(height: 20), // 添加間距
            ElevatedButton(
              onPressed: () {
                // 當按鈕被點擊時，導航到 TargetPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormUploadPage()),
                );
              },
              child: Text('Go to upload Page'), // 按鈕文本
            ),
            SizedBox(height: 20), // 添加間距
            ElevatedButton(
              onPressed: () {
                // 當按鈕被點擊時，導航到 TargetPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnnouncementPage()),
                );
              },
              child: Text('Go to Announcement Page'), // 按鈕文本
            ),
            SizedBox(height: 20), // 添加間距
            ElevatedButton(
              onPressed: () {
                // 當按鈕被點擊時，導航到 TargetPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FileUploadPage()),
                );
              },
              child: Text('Go to FileUpload Page'), // 按鈕文本
            ),
          ],
        ),
      ),
    );
  }
}