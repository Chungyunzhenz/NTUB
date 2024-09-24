import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用指南'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackgroundGradient(), // 背景漸變色
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildWelcomeBanner(context), // 歡迎橫幅
              _buildExpansionTile(
                title: '功能介紹一',
                content: '這是關於功能一的詳細描述。',
                icon: Icons.settings,
              ),
              _buildExpansionTile(
                title: '功能介紹二',
                content: '這是關於功能二的詳細描述。',
                icon: Icons.info_outline,
              ),
              _buildListTile(
                  context, '提供回饋', Icons.feedback, const FeedbackForm()),
              _buildListTile(context, '更新公告', Icons.update, null),
              _buildListTile(context, '常見問題', Icons.help_outline, null),
            ],
          ),
        ],
      ),
    );
  }

  // 背景漸變效果
  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.white],
        ),
      ),
    );
  }

  // 歡迎橫幅
  Widget _buildWelcomeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 93, 219, 241).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundImage: const AssetImage('assets/avatar.png'), // 示例頭像
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '歡迎回來！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '我們很高興為您提供幫助',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 卡片擴展項目
  Widget _buildExpansionTile(
      {required String title,
      required String content,
      required IconData icon}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 76, 208, 245)), // 添加圖示
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(content, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 功能列表卡片
  Widget _buildListTile(
      BuildContext context, String title, IconData icon, Widget? page) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 65, 249, 246)), // 添加圖示
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
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
  const FeedbackForm({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('回饋表單'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '您的回饋',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入您的回饋內容';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('感謝您的回饋！')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(99, 248, 163, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    '提交',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
