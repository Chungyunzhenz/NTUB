import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 's.dart'; // Import the student page
import 'z.dart'; // Import the assistant page
import 't.dart'; // Import the teacher page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://125.229.155.140:5000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'StudentID': _studentIdController.text,
        'Password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      final role = user['Role'];

      if (role == '學生') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentPage(user: user),
          ),
        );
      } else if (role == '助教') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssistantPage(user: user),
          ),
        );
      } else if (role == '老師') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherPage(user: user),
          ),
        );
      } else {
        // Handle other roles or errors
      }
    } else {
      // 處理登入錯誤
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
