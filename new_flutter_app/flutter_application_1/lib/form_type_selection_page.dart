import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';

// 初始化 logger 實例
var logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FormTypeSelectionPage(),
    );
  }
}

class FormTypeSelectionPage extends StatelessWidget {
  const FormTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇表單類型'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const FormUploadPage(formType: '請假單')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('上傳請假單'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const FormUploadPage(formType: '選課單')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('上傳選課單'),
            ),
          ],
        ),
      ),
    );
  }
}

class FormUploadPage extends StatefulWidget {
  final String formType;

  const FormUploadPage({super.key, required this.formType});

  @override
  FormUploadPageState createState() => FormUploadPageState();
}

class FormUploadPageState extends State<FormUploadPage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return; // 確認 widget 是否還掛載

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        logger.w('未選擇圖片。');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final uri = Uri.parse('http://125.229.155.140:5000/upload_image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    if (!mounted) return; // 確認 widget 是否還掛載

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseJson = json.decode(responseData.body);
      logger.i('圖片上傳成功');
      logger.i('圖片路徑: ${responseJson['image_path']}');
      _showUploadStatus('圖片', '上傳成功');
    } else {
      logger.e('圖片上傳失敗');
      _showUploadStatus('圖片', '上傳失敗');
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (!mounted) return; // 確認 widget 是否還掛載

    if (result != null) {
      PlatformFile file = result.files.first;
      // 上傳邏輯
      _showUploadStatus(file.name, '上傳成功');
    } else {
      // 使用者取消選擇
      _showUploadStatus('', '未選擇文件');
    }
  }

  void _showUploadStatus(String fileName, String message) {
    if (!mounted) return; // 確認 widget 是否還掛載

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('上傳狀態'),
        content: Text('文件名: $fileName\n$message'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.formType}上傳'),
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
                  // 可以動態添加更多行
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('選擇文件並上傳'),
            ),
            const SizedBox(height: 20),
            _image == null ? const Text('未選擇圖片。') : Image.file(_image!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('選擇圖片'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('上傳圖片'),
            ),
          ],
        ),
      ),
    );
  }
}
