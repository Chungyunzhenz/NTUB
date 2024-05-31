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

    final uri = Uri.parse('http://125.229.155.140:5000/upload_image');
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
              onPressed: _uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('選擇文件並上傳'),
            ),
            const SizedBox(height: 20),
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: FormUploadPage(),
  ));
}
