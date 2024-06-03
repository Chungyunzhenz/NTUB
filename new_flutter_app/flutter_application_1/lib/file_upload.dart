import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(home: FileUploadPage()));
}

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _file;

  Future<void> pickFile() async {
    // 请求存储权限
    var permission = await Permission.storage.request();

    if (permission.isGranted) {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _file = File(result.files.single.path!);
        });
      }
    } else {
      // 如果用户拒绝权限，您可以在这里处理
      print('Permission denied. Cannot pick the file.');
    }
  }

  Future<void> uploadFile() async {
    if (_file != null) {
      var request = http.MultipartRequest('POST', Uri.parse('http://zctool.8bit.ca:5002/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', _file!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        print('File uploaded');
      } else {
        print('Failed to upload file');
      }
    } else {
      print('No file selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Document'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickFile,
              child: Text('Pick File'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: Text('Upload File'),
            ),
            SizedBox(height: 20),
            Text(_file != null ? 'Selected File: ${_file!.path}' : 'No file selected'),
          ],
        ),
      ),
    );
  }
}
