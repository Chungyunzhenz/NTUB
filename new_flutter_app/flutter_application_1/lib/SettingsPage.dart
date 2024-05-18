import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ValueChanged<String> updateUserName;

  const SettingsPage({super.key, required this.updateUserName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 執行其他功能，例如更改語言設置
                _showLanguageChangeDialog(context);
              },
              child: const Text('更改語言'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('更改語言'),
          content: const Text('此功能尚未實現。'),
          actions: <Widget>[
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
