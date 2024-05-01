// ignore_for_file: file_names, unnecessary_import, use_super_parameters, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart'; // For file handling
import 'package:file_picker/file_picker.dart'; // You need to add 'file_picker' to your pubspec.yaml dependencies

class FormUploadPage extends StatelessWidget {
  const FormUploadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文件上傳'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataTable(
                columnSpacing: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                columns: const [
                  DataColumn(
                      label: Text('文件名',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('狀態',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Icon(Icons.file_upload, color: Colors.blue)),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('example_file.pdf')),
                    DataCell(Text('未上傳')),
                    DataCell(Icon(Icons.file_upload, color: Colors.blue)),
                  ]),
                  // More rows can be added dynamically
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _uploadFile(context),
              child: Text('選擇文件並上傳'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      // Upload logic goes here
      _showUploadStatus(context, file.name, '上傳成功');
    } else {
      // User canceled the picker
      _showUploadStatus(context, '', '没有選擇文件');
    }
  }

  void _showUploadStatus(
      BuildContext context, String fileName, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('上傳狀態'),
        content: Text('文件名: $fileName\n$message'),
        actions: <Widget>[
          TextButton(
            child: Text('關閉'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class SizedBox {}
