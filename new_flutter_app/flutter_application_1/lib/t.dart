import 'package:flutter/material.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key}); // 使用 super 参数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Page'), // 使用 `const`
      ),
      body: const Center( // 使用 `const`
        child: Text('Welcome, Teacher!'), // 使用 `const`
      ),
    );
  }
}
