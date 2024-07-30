import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];
  final TextEditingController keywordController = TextEditingController();
  String searchType = 'academic_year'; // 默认搜索类型

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:4000/history'));

      if (response.statusCode == 200) {
        setState(() {
          historyData = json.decode(response.body);
          print('Fetched history data: $historyData'); // Debug output
        });
      } else {
        throw Exception('Failed to load history data');
      }
    } catch (e) {
      print('Error fetching history data: $e'); // Debug output
      throw Exception('Failed to fetch history data');
    }
  }

  Future<void> searchHistoryData(String keyword) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/search_history'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'type': searchType, 'keyword': keyword}),
      );

      if (response.statusCode == 200) {
        setState(() {
          historyData = json.decode(response.body);
          print('Filtered history data: $historyData'); // Debug output
        });
      } else {
        throw Exception('Failed to search history data');
      }
    } catch (e) {
      print('Error searching history data: $e'); // Debug output
      throw Exception('Failed to search history data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查詢歷史紀錄'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: searchType,
                    onChanged: (String? newValue) {
                      setState(() {
                        searchType = newValue!;
                      });
                    },
                    items: <String>[
                      'academic_year',
                      'course_name',
                      'leave_reason'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(_getSearchTypeLabel(value)),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: keywordController,
                    decoration: InputDecoration(
                      labelText: '輸入查詢關鍵字',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchHistoryData(keywordController.text);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: _buildHistoryList()),
          ],
        ),
      ),
    );
  }

  String _getSearchTypeLabel(String searchType) {
    switch (searchType) {
      case 'academic_year':
        return '學年';
      case 'course_name':
        return '課程名稱';
      case 'leave_reason':
        return '請假原因';
      default:
        return '';
    }
  }

  Widget _buildHistoryList() {
    if (historyData.isEmpty) {
      return Center(child: Text('無歷史紀錄'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: historyData.length,
      itemBuilder: (context, index) {
        final item = historyData[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: item['image_url'] != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(item['image_url']),
                  )
                : null,
            title: Text(
              item['title'] ?? '無標題',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('學年: ${item['academic_year'] ?? '無'}'),
                Text('學期: ${item['period'] ?? '無'}'),
                Text('日期: ${item['date'] ?? '無'}'),
                Text('課程名稱: ${item['course_name'] ?? '無'}'),
                Text('請假原因: ${item['leave_reason'] ?? '無'}'),
                Text('請假表格: ${item['leave_form'] ?? '無'}'),
                Text('選課表格: ${item['course_selection_form'] ?? '無'}'),
                Text('描述: ${item['description'] ?? '無'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: HistoryPage(),
  ));
}
