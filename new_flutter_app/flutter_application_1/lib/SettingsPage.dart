import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ValueChanged<String> updateUserName;
  final ValueChanged<String> updateUserNumber;
  final ValueChanged<String> updateUserProgram;

  const SettingsPage({
    super.key,
    required this.updateUserName,
    required this.updateUserNumber,
    required this.updateUserProgram,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController programController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '個人資訊',
              //style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: nameController,
              labelText: '更改姓名',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: numberController,
              labelText: '更改學號',
              icon: Icons.badge,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: programController,
              labelText: '更改學制',
              icon: Icons.school,
            ),
            const SizedBox(height: 40),
            _buildSaveButton(
              context: context,
              nameController: nameController,
              numberController: numberController,
              programController: programController,
            ),
            const SizedBox(height: 20),
            _buildLanguageButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSaveButton({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController numberController,
    required TextEditingController programController,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        updateUserName(nameController.text);
        updateUserNumber(numberController.text);
        updateUserProgram(programController.text);
        Navigator.pop(context);
      },
      icon: const Icon(Icons.save),
      label: const Text('保存'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _showLanguageChangeDialog(context);
      },
      icon: const Icon(Icons.language),
      label: const Text('更改語言'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Colors.blueGrey,
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

mixin headline6 {}
