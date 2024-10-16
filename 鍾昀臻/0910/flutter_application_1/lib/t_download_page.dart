import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormViewPage extends StatefulWidget {
  const FormViewPage({super.key});

  @override
  FormViewPageState createState() => FormViewPageState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class FormViewPageState extends State<FormViewPage> {
  String? _selectedClass;
  String _searchKeyword = '';
  String _searchType = 'academic_year'; // 默認查詢類型
  String userRole = 'teacher'; // 用戶的角色
  List<Map<String, dynamic>> _classData = [];
  List<Map<String, dynamic>> _studentData = [];

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();
    _fetchClassData();
  }

  // Fetch class data
  Future<void> _fetchClassData() async {
    try {
      final response =
          await http.get(Uri.parse('http://zct.us.kg:5000/api/class_data'));
      if (response.statusCode == 200) {
        setState(() {
          _classData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('獲取班級資料失敗，狀態碼: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('獲取班級資料過程中發生錯誤: $e')),
      );
    }
  }

  // Fetch student data based on class
  Future<void> _fetchStudentData(String className) async {
    try {
      final response = await http.get(Uri.parse(
          'http://zct.us.kg:5000/api/class_students/$className?user_role=$userRole'));
      if (response.statusCode == 200) {
        setState(() {
          _studentData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '獲取學生資料失敗，狀態碼: ${response.statusCode}, 錯誤訊息: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('獲取學生資料過程中發生錯誤: $e')),
      );
    }
  }

  // Fetch history data
  Future<void> _fetchHistoryData() async {
    try {
      final response = await http
          .get(Uri.parse('http://zct.us.kg:5000/api/download_history'));
      if (response.statusCode == 200) {
        setState(() {
          _studentData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('歷史資料已成功加載')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加載歷史資料失敗，狀態碼: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加載歷史資料過程中發生錯誤: $e')),
      );
    }
  }

  // 查看用戶經過過歷表單
  void _showDetailsDialog(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('請假單詳情'),
        content: Text('描述: $description'),
        actions: <Widget>[
          TextButton(
            child: const Text('查看歷史資料'),
            onPressed: () {
              Navigator.of(context).pop();
              _fetchHistoryData(); // 呼叫來加載歷史資料
            },
          ),
          TextButton(
            child: const Text('關閉'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _getHintText(String searchType) {
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

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _searchType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _searchType = newValue!;
                    });
                  },
                  items: [
                    'academic_year',
                    'period',
                    'date',
                    'course_name',
                    'leave_reason',
                    'title',
                    'description'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_getHintText(value)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: _getHintText(_searchType),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchKeyword = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: const Text('所有班請假單歷史紀錄'),
        leading: _selectedClass != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedClass = null;
                    _searchKeyword = '';
                    _studentData = [];
                  });
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchAndFilter(),
            _selectedClass == null
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: _classData.length,
                      itemBuilder: (context, index) {
                        String className = _classData[index]['class_name'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedClass = className;
                              _fetchStudentData(className);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Colors.green[400]!, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder,
                                  color: Colors.green[400],
                                  size: 50.0,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  className,
                                  style: TextStyle(
                                    color: Colors.green[400],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _studentData.length,
                      itemBuilder: (context, index) {
                        var student = _studentData[index];
                        return ListTile(
                          leading: Icon(
                            Icons.file_present,
                            color: Colors.green[400],
                          ),
                          title: Text(student['student_name']),
                          subtitle: Text(student['description']),
                          onTap: () {
                            _showDetailsDialog(context, student['description']);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
