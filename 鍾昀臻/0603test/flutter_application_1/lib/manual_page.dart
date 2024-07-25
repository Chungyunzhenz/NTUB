import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key}); // 使用 super 参数并添加 const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用手冊'), // 使用 const
        backgroundColor: const Color.fromARGB(255, 248, 250, 250), // 设置背景颜色
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0), // 设置边距
        children: [
          _buildExpansionTile('功能介绍一', '這裡是功能一的詳細說明。'),
          _buildExpansionTile('功能介绍二', '這裡是功能二的詳細說明。'),
          _buildListTile(context, '提供回饋', FeedbackForm()),
          _buildListTile(context, '更新公告', null),
          _buildListTile(context, '常見問題', null),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Card(
      elevation: 4, // 设置阴影
      margin: const EdgeInsets.only(bottom: 16.0), // 设置底部间距
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: <Widget>[
          ListTile(title: Text(content)),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, Widget? page) {
    return Card(
      elevation: 4, // 设置阴影
      margin: const EdgeInsets.only(bottom: 16.0), // 设置底部间距
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
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
        backgroundColor: const Color.fromARGB(255, 248, 250, 250), // 设置背景颜色
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 设置边距
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration:
                    const InputDecoration(labelText: '您的回饋'), // 使用 const
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請填寫回饋内容';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // 添加间距
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('感谢您的回饋！')), // 使用 const
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0), // 设置按钮内边距
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 设置按钮圆角
                    ),
                  ),
                  child: const Text('提交'), // 使用 const
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
