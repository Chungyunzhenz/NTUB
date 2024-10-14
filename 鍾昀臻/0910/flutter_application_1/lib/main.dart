import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 's.dart'; // Student Page
import 't.dart'; // Teacher Page
import 'z.dart'; // Assistant Page
import 'package:provider/provider.dart';
import 'theme_notifier.dart'; // 導入 ThemeNotifier

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(false),
      child: const MyApp(),
    ),
  );
}

// void main() {
//   HttpOverrides.global = MyHttpOverrides();
//   runApp(const MyApp());
// }

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final ColorScheme colorScheme = themeNotifier.isDarkMode
        ? const ColorScheme.dark(
            primary: Colors.indigo,
            secondary: Colors.indigoAccent,
          )
        : const ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
          );

    return MaterialApp(
      title: '紙張小精靈',
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: themeNotifier.isDarkMode
            ? Typography.whiteMountainView
            : Typography.blackMountainView,
      ),
      home: LoginPage(
        toggleTheme: themeNotifier.toggleTheme,
        isDarkMode: themeNotifier.isDarkMode,
      ),
    );
  }
}

// class _MyAppState extends State<MyApp> {
//   bool _isDarkMode = false;
//   void _toggleTheme() {
//     setState(() {
//       _isDarkMode = !_isDarkMode;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ColorScheme colorScheme = _isDarkMode
//         ? const ColorScheme.dark(
//             primary: Colors.indigo,
//             secondary: Colors.indigoAccent,
//           )
//         : const ColorScheme.light(
//             primary: Colors.blue,
//             secondary: Colors.blueAccent,
//           );

//     return MaterialApp(
//       title: '紙張小精靈',
//       theme: ThemeData(
//         colorScheme: colorScheme,
//         textTheme: _isDarkMode
//             ? Typography.whiteMountainView
//             : Typography.blackMountainView,
//       ),
//       home: LoginPage(
//         toggleTheme: _toggleTheme,
//         isDarkMode: _isDarkMode,
//       ),
//     );
//   }
// }

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  const LoginPage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('http://zct.us.kg:5000/login'),
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
          setState(() {
            _errorMessage = 'Role or User is missing from the response';
          });
        } else {
          if (role == '老師') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherPage(
                  title: '文件掃描辨識 - 老師',
                  toggleTheme: widget.toggleTheme,
                  isDarkMode: widget.isDarkMode,
                  user: user,
                ),
              ),
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
                ),
              ),
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
                ),
              ),
            );
          } else {
            setState(() {
              _errorMessage = 'Invalid role';
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '紙張小精靈',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _studentIdController,
                        decoration: InputDecoration(
                          labelText: '輸入帳號',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '輸入密碼',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isDarkMode
                              ? const Color.fromARGB(255, 10, 10, 10)
                              : Color.fromARGB(255, 226, 231, 236),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text('登入'),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
