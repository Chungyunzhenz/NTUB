import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 's.dart';
import 't.dart'; // Teacher Page
import 'z.dart'; // Assistant Page
// Student Page


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
      final user = data['user'];
      final role = user['Role'];

      if (role == null || user == null) {
        // 處理 role 或 user 為 null 的情況，例如設置一個錯誤消息
        setState(() {
          _errorMessage = 'Role or User is missing from the response';
        });
      } else {
        // 根據角色導航到不同的頁面
        if (role == '老師') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherPage(
                      title: '文件掃描辨識 - 老師',
                      toggleTheme: widget.toggleTheme,
                      isDarkMode: widget.isDarkMode,
                      user: user,
                    )),
          );
        } else if (role == '助教') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AssistantPage(
                      title: '文件掃描辨識 - 助教',
                      toggleTheme: widget.toggleTheme,
                      isDarkMode: widget.isDarkMode,
                      user: user,
                    )),
          );
        } else if (role == '學生') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => StudentPage(
                      title: '文件掃描辨識 - 學生',
                      toggleTheme: widget.toggleTheme,
                      isDarkMode: widget.isDarkMode,
                      user: user, // Passing the user data here
                    )),
          );
        } else {
          setState(() {
            _errorMessage = 'Invalid role';
          });
        }
      }
    } else {
      // 非 200 狀態碼的錯誤處理
      setState(() {
        _errorMessage = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登入'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: '輸入帳號'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '輸入密碼'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('登入'),
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

class MyHomePage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Map<String, dynamic> user;

  const MyHomePage({
    Key? key,
    required this.user,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${user['Name']}'),
            Text('Role: ${user['Role']}'),
            Text('Academic: ${user['Academic']}'),
            Text('Department: ${user['Department']}'),
          ],
        ),
      ),
    );
  }
}
