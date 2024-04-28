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
            title: Text('功能介绍1'),
            children: <Widget>[
              ListTile(title: Text('这里是功能1的详细说明。')),
            ],
          ),
          ExpansionTile(
            title: Text('功能介绍2'),
            children: <Widget>[
              ListTile(title: Text('这里是功能2的详细说明。')),
            ],
          ),
          ListTile(
            title: Text('提供反馈'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackForm()),
              );
            },
          ),
          ListTile(
            title: Text('更新日志'),
            onTap: () {
              // 弹出或导航到更新日志页面
            },
          ),
          ListTile(
            title: Text('常见问题'),
            onTap: () {
              // 弹出或导航到FAQ页面
            },
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
        title: Text('反馈表单'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: '您的反馈'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请填写反馈内容';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // 处理提交逻辑
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('感谢您的反馈！')),
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
