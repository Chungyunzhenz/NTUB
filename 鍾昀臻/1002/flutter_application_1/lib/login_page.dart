import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 's.dart'; // 學生頁面
import 't.dart'; // 教師頁面
import 'z.dart'; // 助教頁面

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _loginStudent() async {
    // 模擬用戶數據
    final user = {
      'Role': '學生',
      'Name': '示例用戶',
    };

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StudentPage(
          title: '文件掃描辨識 - 學生',
          user: user,
          toggleTheme: themeNotifier.toggleTheme,
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
    );
  }

  Future<void> _loginTeacher() async {
    // 模擬用戶數據
    final user = {
      'Role': '教師',
      'Name': '示例用戶',
    };

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherPage(
          title: '文件掃描辨識 - 教師',
          user: user,
          toggleTheme: themeNotifier.toggleTheme,
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
    );
  }

  Future<void> _loginAssistant() async {
    // 模擬用戶數據
    final user = {
      'Role': '助教',
      'Name': '示例用戶',
    };

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssistantPage(
          title: '文件掃描辨識 - 助教',
          user: user,
          toggleTheme: themeNotifier.toggleTheme,
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeNotifier.isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: themeNotifier.isDarkMode
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.9),
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
                          color: themeNotifier.isDarkMode
                              ? Colors.white
                              : Colors.black,
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
                        onPressed: _loginStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeNotifier.isDarkMode
                              ? const Color.fromARGB(255, 10, 10, 10)
                              : const Color.fromARGB(255, 226, 231, 236),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text('學生登入'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _loginTeacher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeNotifier.isDarkMode
                              ? const Color.fromARGB(255, 10, 10, 10)
                              : const Color.fromARGB(255, 226, 231, 236),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text('教師登入'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _loginAssistant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeNotifier.isDarkMode
                              ? const Color.fromARGB(255, 10, 10, 10)
                              : const Color.fromARGB(255, 226, 231, 236),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text('助教登入'),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: themeNotifier.toggleTheme,
        child: Icon(
          themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        ),
      ),
    );
  }
}
