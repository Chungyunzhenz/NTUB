import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MySQL Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;
  String _error = '';
  Uint8List? _imageData;

  final picker = ImagePicker();

  // 替換為加密後的字符串
  final String _encryptedHost = 'MzQuODAuMTE1LjEyNw==';
  final String _encryptedUser = 'emMx';
  final String _encryptedPassword = 'emN0b29sMDIwNA==';
  final String _encryptedDb = 'emNfc3FsMQ==';
  final String _keyString = 'my32lengthsupersecretnooneknows1'; // 32 chars
  final int _port = 3306;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  String _decrypt(String encryptedText) {
    return utf8.decode(base64Url.decode(encryptedText));
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final conn = await MySqlConnection.connect(ConnectionSettings(
        host: _decrypt(_encryptedHost),
        port: _port,
        user: _decrypt(_encryptedUser),
        password: _decrypt(_encryptedPassword),
        db: _decrypt(_encryptedDb),
      ));

      final results = await conn.query('SELECT * FROM Users');

      final students = results
          .map((row) => {
                'StudentID': row['StudentID'],
                'Password': row['Password'],
                'Name': row['Name'],
                'Phone': row['Phone'],
                'BirthDate': row['BirthDate'],
                'NationalID': row['NationalID'],
                'Role': row['Role'],
                'Academic': row['Academic'],
                'Department': row['Department'],
              })
          .toList();

      setState(() {
        _students = students;
        _isLoading = false;
      });

      await conn.close();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageData = File(pickedFile.path).readAsBytesSync();
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageData == null) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final conn = await MySqlConnection.connect(ConnectionSettings(
        host: _decrypt(_encryptedHost),
        port: _port,
        user: _decrypt(_encryptedUser),
        password: _decrypt(_encryptedPassword),
        db: _decrypt(_encryptedDb),
      ));

      var now = DateTime.now();
      var uploadDate = '${now.year}-${now.month}-${now.day}';
      var id = DateTime.now().millisecondsSinceEpoch.toString();
      var uploadedBy = '00000000001';

      await conn.query(
        'INSERT INTO ImageUploads (ID, Image, UploadDate, UploadedBy) VALUES (?, ?, ?, ?)',
        [id, _imageData, uploadDate, uploadedBy],
      );

      setState(() {
        _isLoading = false;
        _imageData = null;
      });

      await conn.close();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter MySQL Example'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    _students.isEmpty
                        ? Center(child: Text('No students found.'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                return Card(
                                  margin: EdgeInsets.all(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('StudentID: ${student['StudentID']}'),
                                        Text('Password: ${student['Password']}'),
                                        Text('Name: ${student['Name']}'),
                                        Text('Phone: ${student['Phone']}'),
                                        Text('BirthDate: ${student['BirthDate']}'),
                                        Text('NationalID: ${student['NationalID']}'),
                                        Text('Role: ${student['Role']}'),
                                        Text('Academic: ${student['Academic']}'),
                                        Text('Department: ${student['Department']}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    if (_imageData != null)
                      Image.memory(_imageData!),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text('Select Image'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _uploadImage,
                          child: Text('Upload Image'),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
