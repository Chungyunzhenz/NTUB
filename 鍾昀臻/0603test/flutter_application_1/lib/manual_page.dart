import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key}); // 使用 super 参数并添加 const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用手冊'), // 使用 const
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          const ExpansionTile(
            // 使用 const
            title: Text('功能介绍一'),
            children: <Widget>[
              ListTile(title: Text('這裡是功能一的詳細說明。')),
            ],
          ),
          const ExpansionTile(
            // 使用 const
            title: Text('功能介绍二'),
            children: <Widget>[
              ListTile(title: Text('這裡是功能二的詳細說明。')),
            ],
          ),
          ListTile(
            title: const Text('提供回饋'), // 使用 const
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackForm()),
              );
            },
          ),
          ListTile(
            title: const Text('更新公告'), // 使用 const
            onTap: () {},
          ),
          ListTile(
            title: const Text('常見問題'), // 使用 const
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class FeedbackForm extends StatelessWidget {
  FeedbackForm({super.key}); // 使用 super 参数

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('回饋表單'), // 使用 const
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: '您的回饋'), // 使用 const
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請填寫回饋内容';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('感谢您的回饋！')), // 使用 const
                  );
                }
              },
              child: const Text('提交'), // 使用 const
            ),
          ],
        ),
      ),
    );
  }
}
