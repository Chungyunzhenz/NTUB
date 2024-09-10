import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FormDownloadPage extends StatefulWidget {
  const FormDownloadPage({super.key});

  @override
  FormDownloadPageState createState() => FormDownloadPageState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class FormDownloadPageState extends State<FormDownloadPage> {
  String? _selectedClass;
  String? _selectedStudent;
  String _searchKeyword = '';
  String _searchType = 'academic_year'; // 默認查詢類型

  // 班級和學生資料
  final Map<String, List<Map<String, dynamic>>> _classData = {
    '二技一甲': [
      {'name': '張偉', 'file': '張偉資料.pdf'},
      {'name': '李強', 'file': '李強資料.pdf'},
      {'name': '王芳', 'file': '王芳資料.pdf'},
      {'name': '趙麗', 'file': '趙麗資料.pdf'},
    ],
    '二技二甲': [
      {'name': '劉洋', 'file': '劉洋資料.pdf'},
      {'name': '陳超', 'file': '陳超資料.pdf'},
      {'name': '黃萍', 'file': '黃萍資料.pdf'},
      {'name': '周娜', 'file': '周娜資料.pdf'},
    ],
    // 其他班級...
  };

  final Map<String, List<Map<String, String>>> _studentSemesterData = {
    '張偉': [
      {'year': '113', 'file': '學期一選課單.pdf'},
      {'year': '112', 'file': '學期二選課單.pdf'},
    ],
    '李強': [
      {'year': '113', 'file': '學期一選課單.pdf'},
      {'year': '112', 'file': '學期二選課單.pdf'},
    ],
    // 其他學生...
  };

  List<Map<String, dynamic>> get _filteredStudents {
    return _selectedClass == null ? [] : _classData[_selectedClass]!;
  }

  List<Map<String, String>> get _filteredSemesters {
    if (_selectedStudent == null) return [];
    List<Map<String, String>> semesters =
        _studentSemesterData[_selectedStudent]!;
    if (_searchKeyword.isNotEmpty) {
      semesters = semesters
          .where((semester) => semester['file']!.contains(_searchKeyword))
          .toList();
    }
    return semesters;
  }

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  void _showDetailsDialog(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('選課單詳情'),
        content: Text('文件名稱: $fileName'),
        actions: <Widget>[
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

  // 根據選擇的查詢類型返回提示文字
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
        backgroundColor: Colors.orange[400],
        title: const Text('所有班級選課單歷史紀錄'),
        leading: _selectedClass != null || _selectedStudent != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_selectedStudent != null) {
                      _selectedStudent = null;
                      _searchKeyword = '';
                    } else if (_selectedClass != null) {
                      _selectedClass = null;
                      _searchKeyword = '';
                    }
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
                      itemCount: _classData.keys.length,
                      itemBuilder: (context, index) {
                        String className = _classData.keys.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedClass = className;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Colors.orange[400]!, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder,
                                  color: Colors.orange[400],
                                  size: 50.0,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  className,
                                  style: TextStyle(
                                    color: Colors.orange[400],
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
                : _selectedStudent == null
                    ? Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            var student = _filteredStudents[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStudent = student['name'];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color: Colors.orange[400]!, width: 2),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: Colors.orange[400],
                                      size: 50.0,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      student['name'],
                                      style: TextStyle(
                                        color: Colors.orange[400],
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
                          itemCount: _filteredSemesters.length,
                          itemBuilder: (context, index) {
                            var semester = _filteredSemesters[index];
                            return ListTile(
                              leading: Icon(
                                Icons.file_present,
                                color: Colors.orange[400],
                              ),
                              title: Text(semester['file']!),
                              onTap: () {
                                _showDetailsDialog(context, semester['file']!);
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
