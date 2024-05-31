import 'package:flutter/material.dart';

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Page'),
      ),
      body: const Center(
        child: Text('Welcome, Assistant!'),
      ),
    );
  }
}
