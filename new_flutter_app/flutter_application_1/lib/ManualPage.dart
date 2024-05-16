import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('使用手冊'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: Text('功能介绍一'),
            children: <Widget>[
              ListTile(title: Text('這裡是功能一的詳細說明。')),
            ],
          ),
          ExpansionTile(
            title: Text('功能介绍二'),
            children: <Widget>[
              ListTile(title: Text('這裡是功能二的詳細說明。')),
            ],
          ),
          ListTile(
            title: Text('提供回饋'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackForm()),
              );
            },
          ),
          ListTile(
            title: Text('更新公告'),
            onTap: () {},
          ),
          ListTile(
            title: Text('常見問題'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class FeedbackForm extends StatelessWidget {
  FeedbackForm({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('回饋表單'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: '您的回饋'),
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
                    SnackBar(content: Text('感谢您的回饋！')),
                  );
                }
              },
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}
