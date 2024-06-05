import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    home: FileUploadPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _file;

  Future<void> pickFile() async {
    var permission = await Permission.storage.request();

    if (permission.isGranted) {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _file = File(result.files.single.path!);
        });
      }
    } else {
      // 如果用戶拒絕權限，您可以在這裡處理
      print('Permission denied. Cannot pick the file.');
    }
  }

  Future<void> uploadFile() async {
    if (_file != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://zctool.8bit.ca:5002/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', _file!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('成功'),
              content: Text('文件已成功上傳'),
              actions: <Widget>[
                TextButton(
                  child: Text('好的'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('失敗'),
              content: Text('文件上傳失敗'),
              actions: <Widget>[
                TextButton(
                  child: Text('好的'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('錯誤'),
            content: Text('未選擇文件'),
            actions: <Widget>[
              TextButton(
                child: Text('好的'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上傳文件'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '上傳文件',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: pickFile,
                    icon: Icon(Icons.folder_open),
                    label: Text('選擇文件'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: uploadFile,
                    icon: Icon(Icons.cloud_upload),
                    label: Text('上傳文件'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // 使用 backgroundColor 來設置背景顏色
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _file != null
                        ? '選擇的文件: ${_file!.path.split('/').last}'
                        : '未選擇文件',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
