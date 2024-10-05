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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSectionCard(
                          context,
                          title: '功能介紹',
                          description: '了解應用的所有功能。',
                          icon: Icons.settings,
                          page: _buildFunctionIntroductionPage(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSectionCard(
                          context,
                          title: '幫助中心',
                          description: '獲取幫助和解決常見問題。',
                          icon: Icons.help_outline,
                          page: _buildHelpCenterPage(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSectionCard(
                          context,
                          title: '回饋與設定',
                          description: '提供回饋或修改應用設定。',
                          icon: Icons.feedback,
                          page: const FeedbackForm(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  // 每個區塊卡片設計
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Widget page,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 功能介紹頁面
  Widget _buildFunctionIntroductionPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能介紹'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExpansionTile(
            title: '功能介紹一 上傳功能',
            content: '這是關於功能一的詳細描述。',
            icon: Icons.settings,
            status: '進行中',
          ),
          _buildExpansionTile(
            title: '功能介紹一 智能小幫手',
            content: '這是關於功能一的詳細描述。',
            icon: Icons.settings,
            status: '進行中',
          ),
          _buildExpansionTile(
            title: '功能介紹一 歷史紀錄',
            content: '這是關於功能一的詳細描述。',
            icon: Icons.settings,
            status: '已完成',
          ),
          _buildExpansionTile(
            title: '功能介紹二 上傳紀錄',
            content: '這是關於功能二的詳細描述。',
            icon: Icons.info_outline,
            status: '已完成',
          ),
        ],
      ),
    );
  }

  // 幫助中心頁面
  Widget _buildHelpCenterPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('幫助中心'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildListTile(
            context: null,
            title: '常見問題',
            icon: Icons.help_outline,
            page: null,
          ),
          _buildListTile(
            context: null,
            title: '更新公告',
            icon: Icons.update,
            page: null,
          ),
        ],
      ),
    );
  }

  // 卡片擴展項目，帶有狀態標籤
  Widget _buildExpansionTile({
    required String title,
    required String content,
    required IconData icon,
    required String status,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 76, 208, 245)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: status == '已完成'
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == '已完成' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
  Widget _buildListTile({
    required BuildContext? context,
    required String title,
    required IconData icon,
    required Widget? page,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 65, 249, 246)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (context != null && page != null) {
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

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _feedbackLength = 0;
  final int _maxFeedbackLength = 200; // 限制字數

  @override
  Widget build(BuildContext context) {
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
                maxLength: _maxFeedbackLength,
                onChanged: (value) {
                  setState(() {
                    _feedbackLength = value.length;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入您的回饋內容';
                  }
                  return null;
                },
              ),
              Text(
                '已輸入字數：$_feedbackLength/$_maxFeedbackLength',
                style: const TextStyle(color: Colors.grey),
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
