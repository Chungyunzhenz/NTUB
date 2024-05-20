import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'AnnouncementPage.dart';
import 'FormDownloadPage.dart';
import 'FormUploadPage.dart';
import 'ManualPage.dart';

void main() {
  runApp(const MyApp());
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

class LoginPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  LoginPage({required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('登入')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: '用戶名'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String role = _getRole(usernameController.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      role: role,
                      toggleTheme: toggleTheme,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              },
              child: const Text('登入'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpPage(),
                  ),
                );
              },
              child: const Text('註冊新帳號'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRole(String username) {
    if (username.contains('助教')) {
      return '助教';
    } else if (username.contains('老師')) {
      return '老師';
    } else {
      return '學生';
    }
  }
}

class SignUpPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('註冊')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: '用戶名'),
            ),
            Text(
              '學生請使用學號註冊；老師及助教請使用英文名稱註冊。',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            Text(
              '學生請使用學號作為密碼；老師及助教請使用英文名稱作為密碼。',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: '確認密碼'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == confirmPasswordController.text) {
                  Navigator.pop(context);
                } else {
                  // 顯示錯誤信息
                }
              },
              child: const Text('註冊'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String role;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  HomePage(
      {required this.role,
      required this.toggleTheme,
      required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return role == '學生'
        ? MyHomePage(
            title: '文件掃描辨識 - 學生',
            toggleTheme: toggleTheme,
            isDarkMode: isDarkMode)
        : role == '助教'
            ? AssistantHomePage(
                title: '文件掃描辨識 - 助教',
                toggleTheme: toggleTheme,
                isDarkMode: isDarkMode)
            : TeacherHomePage(
                title: '文件掃描辨識 - 老師',
                toggleTheme: toggleTheme,
                isDarkMode: isDarkMode);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.toggleTheme,
      required this.isDarkMode});
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userName = '王小華';
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode)),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: Column(
                children: [
                  CircleAvatar(),
                  SizedBox(height: 10),
                  Text('主選單',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
            _createDrawerItem(Icons.public, '校園公告', const AnnouncementPage()),
            _createDrawerItem(Icons.download, '表單下載', const FormDownloadPage()),
            _createDrawerItem(
                Icons.upload_file, '表單上傳', const FormUploadPage()),
            _createDrawerItem(Icons.book, '使用手冊', const ManualPage()),
            _createDrawerItem(
                Icons.settings,
                '個人資料',
                SettingsPage(
                    updateUserName: _updateUserName,
                    pickImage: _pickImage,
                    image: _image)),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          _buildWelcomeMessage(),
          _buildProfileCard(context),
          _buildFeatureSection(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: '開啟 Line Bot',
        backgroundColor: Colors.green,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _createDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  void _updateUserName(String newUserName) {
    setState(() {
      userName = newUserName;
    });
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '歡迎, $userName!',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800]),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('姓名：$userName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('科系：資訊管理系'),
            const Text('學制：日間部二技'),
            const Text('學號：11236099'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('主要功能',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800])),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: <Widget>[
              _buildFeatureCard('校園公告', Icons.public, Colors.blue, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnnouncementPage()));
              }),
              _buildFeatureCard('表單下載', Icons.download, Colors.green, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormDownloadPage()));
              }),
              _buildFeatureCard('表單上傳', Icons.upload_file, Colors.red, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormUploadPage()));
              }),
              _buildFeatureCard('使用手冊', Icons.book, Colors.orange, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManualPage()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class AssistantHomePage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  AssistantHomePage(
      {required this.title,
      required this.toggleTheme,
      required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(
                        toggleTheme: toggleTheme, isDarkMode: isDarkMode)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('助教專用介面'),
      ),
    );
  }
}

class TeacherHomePage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  TeacherHomePage(
      {required this.title,
      required this.toggleTheme,
      required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(
                        toggleTheme: toggleTheme, isDarkMode: isDarkMode)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('老師專用介面'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final ValueChanged<String> updateUserName;
  final VoidCallback pickImage;
  final File? image;

  const SettingsPage(
      {super.key,
      required this.updateUserName,
      required this.pickImage,
      required this.image});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('個人資料')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: image != null ? FileImage(image!) : null,
            ),
            TextButton(
              onPressed: pickImage,
              child: const Text('選擇頭像'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '更改姓名'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateUserName(nameController.text);
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
