import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart'; // For file handling
import 'package:file_picker/file_picker.dart'; // Ensure file_picker is added to your pubspec.yaml
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class FormUploadPage extends StatefulWidget {
  const FormUploadPage({Key? key}) : super(key: key);

  @override
  _FormUploadPageState createState() => _FormUploadPageState();
}

class _FormUploadPageState extends State<FormUploadPage> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _ipController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null ) return;

    final uri = Uri.parse('http://125.229.155.140:5000:5000/upload_image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseJson = json.decode(responseData.body);
      print('Image uploaded successfully');
      print('Image path: ${responseJson['image_path']}');
      _showUploadStatus(context, 'Image', '上傳成功');
    } else {
      print('Failed to upload image');
      _showUploadStatus(context, 'Image', '上傳失敗');
    }
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
            ),
            SizedBox(height: 20),
            
            _image == null ? Text('No image selected.') : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FormUploadPage(),
  ));
}
