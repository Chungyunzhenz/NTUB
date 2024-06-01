import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'announcement_page.dart';
import 'form_download_page.dart';
import 'form_upload_page.dart';
import 'manual_page.dart';
import 't.dart'; // Teacher Page
import 'z.dart'; // Assistant Page
import 's.dart'; // Student Page

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文件掃描辨識',
      theme: _isDarkMode
          ? ThemeData.dark()
          : ThemeData(
              primaryColor: Colors.blue[800],
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Colors.blue[800],
                secondary: Colors.blue[400],
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue[800],
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.blue[400],
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
      home: LoginPage(
        toggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const LoginPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://zctool.8bit.ca:5000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'StudentID': _studentIdController.text,
        'Password': _passwordController.text,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String role = data['role'];

      if (role == '老師') {
        setState(() {
          _errorMessage = '';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TeacherPage(
                    title: '文件掃描辨識 - 老師',
                    toggleTheme: widget.toggleTheme,
                    isDarkMode: widget.isDarkMode,
                  )),
        );
      } else if (role == '助教') {
        setState(() {
          _errorMessage = '';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AssistantPage(
                    title: '文件掃描辨識 - 助教',
                    toggleTheme: widget.toggleTheme,
                    isDarkMode: widget.isDarkMode,
                  )),
        );
      } else if (role == '學生') {
        setState(() {
          _errorMessage = '';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    title: '文件掃描辨識 - 學生',
                    toggleTheme: widget.toggleTheme,
                    isDarkMode: widget.isDarkMode,
                  )),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid Student ID or Password';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid Student ID or Password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
