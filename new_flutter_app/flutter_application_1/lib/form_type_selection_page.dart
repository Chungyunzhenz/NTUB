import 'package:flutter/material.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'form_upload_page.dart';

class FormTypeSelectionPage extends StatelessWidget {
  const FormTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇表單類型'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedButton(
              context,
              icon: Icons.assignment,
              label: '上傳請假單',
              formType: '請假單',
            ),
            const SizedBox(height: 20),
            _buildAnimatedButton(
              context,
              icon: Icons.book,
              label: '上傳選課單',
              formType: '選課單',
            ),
          ],
        ),
      ).animate().fadeIn(duration: Duration(milliseconds: 800)).scale(),
    );
  }

  Widget _buildAnimatedButton(BuildContext context,
      {required IconData icon,
      required String label,
      required String formType}) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FormUploadPage(formType: formType)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
    ).animate().scale();
  }
}
