import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';

// Initialize a logger instance
var logger = Logger();

class FormUploadPage extends StatefulWidget {
  const FormUploadPage({super.key});

  @override
  FormUploadPageState createState() => FormUploadPageState();
}

class FormUploadPageState extends State<FormUploadPage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        logger.w('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final uri = Uri.parse('http://zct.us.kg:5000/upload_image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    if (!mounted) return; // Check if the widget is still mounted

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseJson = json.decode(responseData.body);
      logger.i('Image uploaded successfully');
      logger.i('Image path: ${responseJson['image_path']}');
      _showUploadStatus('Image', '上傳成功');
    } else {
      logger.e('Failed to upload image');
      _showUploadStatus('Image', '上傳失敗');
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (!mounted) return; // Check if the widget is still mounted

    if (result != null) {
      PlatformFile file = result.files.first;
      // Upload logic goes here
      _showUploadStatus(file.name, '上傳成功');
    } else {
      // User canceled the picker
      _showUploadStatus('', '沒有選擇文件');
    }
  }

  void _showUploadStatus(String fileName, String message) {
    if (!mounted) return; // Check if the widget is still mounted

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
        title: const Text('文件上傳'),
        backgroundColor: Theme.of(context).primaryColor, // 使用主题的主色调
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
                    '文件上傳',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _uploadFile,
                    icon: Icon(Icons.upload_file),
                    label: const Text('選擇文件並上傳'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 145, 181, 243),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _image == null ? const Text('未選擇圖片') : Image.file(_image!),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: const Text('選擇圖片'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 145, 181, 243),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _uploadImage,
                    icon: Icon(Icons.cloud_upload),
                    label: const Text('上傳圖片'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 145, 181, 243),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
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

void main() {
  runApp(MaterialApp(
    home: FormUploadPage(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
