import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MySQL Connect TEST',
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

  final String _encryptedHost = 'MzQuODAuMTE1LjEyNw==';
  final String _encryptedUser = 'emMx';
  final String _encryptedPassword = 'emN0b29sMDIwNA==';
  final String _encryptedDb = 'emNfc3FsMQ==';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter MySQL Connect TEST'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : _students.isEmpty
                  ? Center(child: Text('No students found.'))
                  : ListView.builder(
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
    );
  }
}
