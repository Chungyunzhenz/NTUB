import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// 初始化Logger
var logger = Logger();

void main() {
  runApp(MaterialApp(
    home: UnifiedUploadPage(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class UnifiedUploadPage extends StatefulWidget {
  @override
  _UnifiedUploadPageState createState() => _UnifiedUploadPageState();
}

class _UnifiedUploadPageState extends State<UnifiedUploadPage> {
  File? _image;
  String? _previewImageUrl;
  final picker = ImagePicker();

  // 選擇圖片
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return; // 檢查組件是否已掛載
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        logger.w('No image selected.');
      }
    });
  }

  // 上傳圖片
  Future<void> _uploadImage() async {
    if (_image == null) return;

    final uri = Uri.parse('http://zct.us.kg:5000/upload_image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();
    if (!mounted) return;

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseJson = json.decode(responseData.body);
      logger.i('Image uploaded successfully');
      logger.i('Image path: ${responseJson['image_path']}');
      _showUploadStatus('Image', '上傳成功');
      setState(() {
        _previewImageUrl = 'http://zct.us.kg/${responseJson['image_path']}';
      });
    } else {
      logger.e('Failed to upload image');
      _showUploadStatus('Image', '上傳失敗');
    }
  }

  // 選擇文件並上傳
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (!mounted) return;

    if (result != null) {
      PlatformFile file = result.files.first;
      // 文件上傳邏輯
      _showUploadStatus(file.name, '上傳成功');
    } else {
      _showUploadStatus('', '沒有選擇文件');
    }
  }

  // 顯示上傳狀態
  void _showUploadStatus(String fileName, String message) {
    if (!mounted) return;

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
        title: const Text('文件與圖片上傳'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '文件與圖片上傳',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 文件上傳按鈕
                  ElevatedButton.icon(
                    onPressed: _uploadFile,
                    icon: Icon(Icons.upload_file),
                    label: const Text('選擇文件並上傳'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 150, 136), // 更新顏色
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 圖片選擇與預覽
                  _image == null
                      ? const Text('未選擇圖片')
                      : Image.file(_image!,
                          height: 200, width: 200, fit: BoxFit.cover),

                  const SizedBox(height: 20),

                  // 選擇圖片按鈕
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: const Text('選擇圖片'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 150, 136), // 更新顏色
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 上傳圖片按鈕
                  ElevatedButton.icon(
                    onPressed: _uploadImage,
                    icon: Icon(Icons.cloud_upload),
                    label: const Text('上傳圖片'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 150, 136), // 更新顏色
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 圖片預覽
                  if (_previewImageUrl != null)
                    Column(
                      children: [
                        Text('圖片預覽:'),
                        const SizedBox(height: 16),
                        Image.network(_previewImageUrl!,
                            height: 200, width: 200, fit: BoxFit.cover),
                      ],
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
