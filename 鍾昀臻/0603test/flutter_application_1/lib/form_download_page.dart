import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FormDownloadPage extends StatefulWidget {
  const FormDownloadPage({super.key});

  @override
  FormDownloadPageState createState() => FormDownloadPageState();
}

class FormDownloadPageState extends State<FormDownloadPage> {
  String? _selectedDepartment;
  bool _isDownloading = false;

  final List<Map<String, dynamic>> _forms = [
    {
      'name': '選課單',
      'department': '科系',
      'file': '選課單.docx',
      'url': 'https://example.com/選課單.docx',
    },
    {
      'name': '請假單',
      'department': '學務處',
      'file': '請假單.odt',
      'url': 'https://example.com/請假單.odt',
    },
  ];

  Future<void> _downloadFile(String fileName, String fileUrl) async {
    try {
      setState(() => _isDownloading = true);
      await requestPermissions();
      var dio = Dio();
      var response = await dio.get(
        fileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );
      final Directory? directory = await getExternalStorageDirectory();
      final String newPath = path.join(directory!.path, fileName);
      File file = File(newPath);
      await file.writeAsBytes(response.data);
      _showDownloadSuccessDialog(newPath);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  void _showDownloadSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('下載成功'),
        content: Text('文件已下載至: $filePath'),
        actions: [
          TextButton(
            child: const Text('關閉'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('下載失敗'),
        content: Text('錯誤: $errorMessage'),
        actions: [
          TextButton(
            child: const Text('關閉'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下載表單'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text('選擇科系'),
              value: _selectedDepartment,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue;
                });
              },
              items: <String>['科系', '學務處']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _forms.length,
              itemBuilder: (context, index) {
                var form = _forms[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(form['name']),
                    subtitle: Text(form['department']),
                    trailing: _isDownloading
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () =>
                                _downloadFile(form['file'], form['url']),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: FormDownloadPage()));
}
