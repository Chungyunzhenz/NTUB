import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 's.dart'; // 學生頁面
import 't.dart'; // 教師頁面
import 'z.dart'; // 助教頁面
import 'theme_notifier.dart'; // 引入 ThemeNotifier 以便切換主題

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final role = user['Role'];

        final themeNotifier =
            Provider.of<ThemeNotifier>(context, listen: false);

        // 根據不同角色的頁面跳轉邏輯
        if (role == 'student') {
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
        } else if (role == 'assistant') {
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
        } else if (role == 'teacher') {
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
        } else {
          // 處理其他角色或錯誤情況
          setState(() {
            _errorMessage = '無效的用戶角色。';
          });
        }
      } else {
        // 處理登入錯誤
        setState(() {
          _errorMessage = '登入失敗，請重試。';
        });
      }
    } catch (e) {
      // 處理異常錯誤
      setState(() {
        _errorMessage = '發生錯誤，請檢查網絡連接。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登入'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(
                labelText: '輸入帳號',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
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
