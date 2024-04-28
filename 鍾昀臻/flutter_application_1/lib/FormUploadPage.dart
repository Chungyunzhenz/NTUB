import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class FormUploadPage extends StatelessWidget {
  const FormUploadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('文件上傳'),
        backgroundColor: theme.colorScheme.primary,
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
                  border: Border.all(color: theme.colorScheme.primary),
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
                  DataColumn(
                      label: Icon(Icons.check_circle_outline,
                          color: Colors.green)),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('example_file.pdf')),
                    DataCell(Text('未上傳')),
                    DataCell(Icon(Icons.file_upload, color: Colors.blue)),
                    DataCell(LinearProgressIndicator(value: 0.5)), // 示例進度條
                  ]),
                  // More rows can be added dynamically
                ],
              ),
            ),
            SizedBox(height: 20),
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
      _showUploadStatus(context, '', '沒有選擇文件');
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
