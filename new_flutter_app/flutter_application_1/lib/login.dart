import 'package:flutter/material.dart';

// 定義 LoginPage 狀態控制元件
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

// 定義 LoginPage 的狀態
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // 定義表單的鍵，用於驗證和儲存表單
  String _email = ''; // 儲存用戶輸入的電子郵件
  String _password = ''; // 儲存用戶輸入的密碼

  // 嘗試登入的方法
  void _tryLogin() {
    if (_formKey.currentState?.validate() == true) {
      // 驗證表單輸入
      _formKey.currentState?.save(); // 儲存表單資料
      print('Email: $_email'); // 輸出電子郵件
      print('Password: $_password'); // 輸出密碼
      // 導航到首頁，並替換當前頁面
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'), // AppBar 標題
      ),
      body: Center(
        // 中央佈局
        child: SingleChildScrollView(
          // 可滾動的單一子項容器
          child: Form(
            key: _formKey, // 表單鍵
            child: Padding(
              // 增加內邊距
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                children: <Widget>[
                  Image.asset(
                    // 添加圖片
                    'assets/image/genie.png',
                    height: 150,
                  ),
                  SizedBox(height: 20), // 增加間距
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email', // 標籤文字
                      hintText: 'Enter your email', // 提示文字
                      border: OutlineInputBorder(), // 邊框樣式
                    ),
                    validator: (value) {
                      // 驗證輸入
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email'; // 驗證失敗提示
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // 儲存輸入
                      _email = value ?? '';
                    },
                  ),
                  SizedBox(height: 10), // 增加間距
                  TextFormField(
                    obscureText: true, // 隱藏文字
                    decoration: InputDecoration(
                      labelText: 'Password', // 標籤文字
                      hintText: 'Enter your password', // 提示文字
                      border: OutlineInputBorder(), // 邊框樣式
                    ),
                    validator: (value) {
                      // 驗證輸入
                      if (value == null || value.isEmpty || value.length < 5) {
                        return 'Password must be at least 5 characters long'; // 驗證失敗提示
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // 儲存輸入
                      _password = value ?? '';
                    },
                  ),
                  SizedBox(height: 20), // 增加間距
                  ElevatedButton(
                    onPressed: _tryLogin, // 點擊按鈕執行登入
                    child: Text('Login'), // 按鈕文字
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 定義首頁
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'), // AppBar 標題
      ),
      body: Center(
        // 中央佈局
        child: Text('Welcome to the Home Page!'), // 中央文本
      ),
    );
  }
}
