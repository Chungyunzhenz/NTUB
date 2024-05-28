import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _storage = FlutterSecureStorage();

  Future<void> _login() async {
    final studentId = _studentIdController.text;
    final password = _passwordController.text;

    if (studentId.isEmpty || password.isEmpty) {
      _showError('Please enter both StudentID and Password');
      return;
    }

    final response = await http.post(
      Uri.parse('http://125.229.155.140:5000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'StudentID': studentId,
        'Password': password,
      }),
    );

    if (response.statusCode == 200) {
      await _storage.write(key: 'user', value: response.body);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()), // 这里应该导航到具体的页面，而不是 main
      );
    } else {
      final error = jsonDecode(response.body)['error'];
      _showError(error);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(labelText: 'StudentID'),
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

class _storage {
  static Future<void> write(
      {required String key, required String value}) async {
    // 模拟存储行为，可以使用 SharedPreferences 或其他存储机制
    print('Key: $key, Value: $value');
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
