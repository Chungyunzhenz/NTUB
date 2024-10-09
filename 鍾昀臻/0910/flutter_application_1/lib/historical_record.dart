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
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  @override
  void dispose() {
    keywordController.dispose();
    super.dispose();
  }

  Future<void> fetchHistoryData() async {
    try {
      final response = await http
          .get(Uri.parse('http://zct.us.kg:5000/history')); //zct.us.kg:5000

      if (response.statusCode == 200) {
        setState(() {
          historyData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load history data';
          isLoading = false;
        });
        _showSnackbar('Failed to load history data');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching history data: $e';
        isLoading = false;
      });
      _showSnackbar('Error fetching history data');
    }
  }

  Future<void> searchHistoryData(String keyword) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://zct.us.kg:5000/filter_history'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'type': searchType, 'keyword': keyword}),
      );

      if (response.statusCode == 200) {
        setState(() {
          historyData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to search history data';
          isLoading = false;
        });
        _showSnackbar('Failed to search history data');
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error searching history data: $e';
        isLoading = false;
      });
      _showSnackbar('Error searching history data');
      print('Exception caught: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查詢歷史紀錄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: searchType,
                    decoration: InputDecoration(
                      labelText: '選擇查詢類型',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        searchType = newValue!;
                      });
                    },
                    items: <String>[
                      'academic_year',
                      'period',
                      'date',
                      'course_name',
                      'leave_reason',
                      'title',
                      'description'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(_getSearchTypeLabel(value)),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: keywordController,
                    decoration: InputDecoration(
                      labelText: '輸入查詢關鍵字',
                      border: OutlineInputBorder(),
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
            SizedBox(height: 16),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
            else
              Expanded(child: _buildHistoryList()),
          ],
        ),
      ),
    );
  }

  String _getSearchTypeLabel(String searchType) {
    switch (searchType) {
      case 'academic_year':
        return '學年(113-104)';
      case 'period':
        return '學期(1：上學期、2：下學期)';
      case 'date':
        return '日期(格式：xxxx/xx-xx/xxxx-xx-xx)';
      case 'course_name':
        return '課程名稱';
      case 'leave_reason':
        return '請假原因';
      case 'title':
        return '表單種類(請假單or選課單)';
      case 'description':
        return '描述';
      default:
        return '';
    }
  }

  Widget _buildHistoryList() {
    if (historyData.isEmpty) {
      return Center(child: Text('無歷史紀錄'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: historyData.length,
      itemBuilder: (context, index) {
        final item = historyData[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: item['image_url'] != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(item['image_url']),
                  )
                : CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 72, 216, 245),
                    child: Icon(Icons.school, color: Colors.white),
                  ),
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
                Text('描述: ${item['description'] ?? '無'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Color.fromARGB(255, 72, 216, 245),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: HistoryPage(),
  ));
}
