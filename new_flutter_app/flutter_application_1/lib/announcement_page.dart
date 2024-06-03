import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key}); // Added key parameter

  @override
  AnnouncementPageState createState() => AnnouncementPageState();
}

class AnnouncementPageState extends State<AnnouncementPage> {
  // Changed to public
  List announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final response = await http
          .get(Uri.parse('http://125.229.155.140:5000/announcements'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            announcements = data['announcements'];
            isLoading = false;
          });
        }
      } else {
        // Handle server errors
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to load announcements. Server error.')),
          );
        }
      }
    } catch (e) {
      // Handle network errors
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load announcements. Network error.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return ListTile(
                  title: Text(announcement['Purpose']),
                  subtitle: Text(announcement['content']),
                );
              },
            ),
    );
  }
}
