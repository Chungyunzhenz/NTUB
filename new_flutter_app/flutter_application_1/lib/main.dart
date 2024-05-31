import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'announcement_page.dart';
import 'form_download_page.dart';
import 'form_upload_page.dart';
import 'manual_page.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
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

  const LoginPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

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
                    builder: (context) => const SignUpPage(),
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

// 註冊頁面
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

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

// 首頁
class HomePage extends StatelessWidget {
  final String role;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.role,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme;
    if (role == '學生') {
      theme = _buildTheme(Colors.blue);
    } else if (role == '助教') {
      theme = _buildTheme(Colors.yellow);
    } else {
      theme = _buildTheme(Colors.purple);
    }

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('文件掃描辨識 - $role'),
          actions: <Widget>[
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
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
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                ),
                child: Column(
                  children: [
                    const CircleAvatar(),
                    const SizedBox(height: 10),
                    const Text('主選單',
                        style: TextStyle(color: Colors.white, fontSize: 24)),
                  ],
                ),
              ),
              _createDrawerItem(
                  icon: Icons.public,
                  text: '校園公告',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnnouncementPage(),
                        ));
                  }),
              _createDrawerItem(
                  icon: Icons.download,
                  text: '表單下載',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormDownloadPage(),
                        ));
                  }),
              _createDrawerItem(
                  icon: Icons.upload_file,
                  text: '表單上傳',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormUploadPage(),
                        ));
                  }),
              _createDrawerItem(
                  icon: Icons.book,
                  text: '使用手冊',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManualPage(),
                        ));
                  }),
              _createDrawerItem(
                  icon: Icons.settings,
                  text: '個人資料',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                            updateUserName: (newUserName) {
                              // 更新用户名称
                            },
                            pickImage: () {
                              // 选择图片
                            },
                            image: null,
                          ),
                        ));
                  }),
            ],
          ),
        ),
        body: _buildRoleBasedPage(role),
      ),
    );
  }

  ThemeData _buildTheme(Color color) {
    return ThemeData(
      primaryColor: color,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: color,
        secondary: color.withOpacity(0.7),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: color,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color.withOpacity(0.7),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      GestureTapCallback? onTap}) {
    return ListTile(
      title: Text(text),
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  Widget _buildRoleBasedPage(String role) {
    if (role == '學生') {
      return MyHomePage(
          title: '文件掃描辨識 - 學生',
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode);
    } else if (role == '助教') {
      return AssistantHomePage(
          title: '文件掃描辨識 - 助教',
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode);
    } else {
      return TeacherHomePage(
          title: '文件掃描辨識 - 老師',
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode);
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  });

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

  void _updateUserName(String newUserName) {
    setState(() {
      userName = newUserName;
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
            icon: const Icon(Icons.logout),
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
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  const CircleAvatar(),
                  const SizedBox(height: 10),
                  const Text('主選單',
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
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '歡迎，$userName',
        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : const AssetImage('assets/avatar_placeholder.png')
                      as ImageProvider,
            ),
            title: Text(userName),
            subtitle: const Text('學生'),
          ),
          ButtonBar(
            children: <Widget>[
              TextButton(
                child: const Text('編輯個人資料'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(
                            updateUserName: _updateUserName,
                            pickImage: _pickImage,
                            image: _image)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.assignment),
          title: const Text('功能介紹'),
          onTap: () {
            // Handle tap
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('常見問題'),
          onTap: () {
            // Handle tap
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('關於'),
          onTap: () {
            // Handle tap
          },
        ),
      ],
    );
  }
}

// 助教首頁
class AssistantHomePage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AssistantHomePage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  });

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
            icon: const Icon(Icons.logout),
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
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  const CircleAvatar(),
                  const SizedBox(height: 10),
                  const Text('主選單',
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
                    updateUserName: (newUserName) {
                      // 更新用户名称
                    },
                    pickImage: () {
                      // 选择图片
                    },
                    image: null)),
          ],
        ),
      ),
      body: const Center(child: Text('助教首頁')),
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
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}

// 老師首頁
class TeacherHomePage extends StatelessWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const TeacherHomePage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  });

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
            icon: const Icon(Icons.logout),
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
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  const CircleAvatar(),
                  const SizedBox(height: 10),
                  const Text('主選單',
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
                    updateUserName: (newUserName) {
                      // 更新用户名称
                    },
                    pickImage: () {
                      // 选择图片
                    },
                    image: null)),
          ],
        ),
      ),
      body: const Center(child: Text('老師首頁')),
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
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}

// 個人資料頁面
class SettingsPage extends StatelessWidget {
  final Function(String) updateUserName;
  final VoidCallback pickImage;
  final File? image;

  const SettingsPage({
    super.key,
    required this.updateUserName,
    required this.pickImage,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('個人資料')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: '用戶名'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateUserName(usernameController.text);
                Navigator.pop(context);
              },
              child: const Text('更新資料'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('選擇圖片'),
            ),
            const SizedBox(height: 20),
            image != null ? Image.file(image!) : const Text('尚未選擇圖片'),
          ],
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
