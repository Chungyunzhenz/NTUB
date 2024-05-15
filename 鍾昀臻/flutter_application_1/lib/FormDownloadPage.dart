// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FormDownloadPage extends StatelessWidget {
  // ignore: use_super_parameters
  const FormDownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('檔案下載'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.blue),
            title: Text('選課手冊 2024'),
            subtitle: Text('更新日期：2024-04-01'),
            trailing: IconButton(
              icon: Icon(Icons.file_download, color: Colors.blue),
              onPressed: () {
                // 添加下载文件的逻辑
                _downloadFile(context, '選課手冊 2024');
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.blue),
            title: Text('請假表格'),
            subtitle: Text('更新日期：2024-05-21'),
            trailing: IconButton(
              icon: Icon(Icons.file_download, color: Colors.blue),
              onPressed: () {
                // 添加下载文件的逻辑
                _downloadFile(context, '請假表格');
              },
            ),
          ),
          // 可以继续添加更多文件
        ],
      ),
    );
  }

  void _downloadFile(BuildContext context, String fileName) {
    final snackBar = SnackBar(content: Text('正在下载文件：$fileName'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
