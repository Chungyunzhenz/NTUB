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
  List<Map<String, dynamic>> _studentData = [];

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();
  }

  // Fetch student data based on class
  Future<void> _fetchStudentData(String className) async {
    try {
      setState(() {
        _studentData = List<Map<String, dynamic>>.from(
            _hardCodedStudents(className).map((data) {
          data['student_name'] ??= '未知學生';
          data['description'] ??= '無描述';
          data['userid'] ??= '';
          return data;
        }));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('獲取學生資料過程中發生錯誤: $e')),
      );
    }
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
                      itemCount: _hardCodedClassNames().length,
                      itemBuilder: (context, index) {
                        String className = _hardCodedClassNames()[index];
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
                            Icons.folder,
                            color: Colors.green[400],
                          ),
                          title: Text(student['student_name'] ?? '未知學生'),
                          subtitle: Text(student['description'] ?? '無描述'),
                          onTap: () {
                            if (student['userid'] == 'WET8644G3S463' &&
                                userRole == 'teacher') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailsPage(
                                    userid: student['userid'],
                                    title: '請假單',
                                  ),
                                ),
                              );
                            } else if (student['userid'] == 'WET8644G3S463' &&
                                userRole == 'assistant') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailsPage(
                                    userid: student['userid'],
                                    title: '選課單',
                                  ),
                                ),
                              );
                            }
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

  List<String> _hardCodedClassNames() {
    return ['二技一甲', '二技二甲', '四技一甲', '四技二甲', '四技三甲', '四技四甲'];
  }

  List<Map<String, String>> _hardCodedStudents(String className) {
    switch (className) {
      case '二技一甲':
        return [
          {
            'student_id': 'S001',
            'student_name': '張三',
            'userid': 'WET8644G3S463'
          },
          {'student_id': 'S002', 'student_name': '李四', 'userid': 'S002'},
        ];
      case '二技二甲':
        return [
          {'student_id': 'S003', 'student_name': '王五', 'userid': 'S003'},
          {'student_id': 'S004', 'student_name': '趙六', 'userid': 'S004'},
        ];
      default:
        return [];
    }
  }
}

class StudentDetailsPage extends StatelessWidget {
  final String userid;
  final String title;

  const StudentDetailsPage({
    Key? key,
    required this.userid,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('學生資料詳情'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchReviewProgress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('加載資料過程中發生錯誤: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('沒有找到資料'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return ListTile(
                  title: Text(
                      '${item['submission_date'].split(" ")[3]}年 ${item['submission_date'].split(" ")[2]}'),
                  subtitle: Text('${item['title']}'),
                  onTap: () {
                    _showDetailsDialog(context, item);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchReviewProgress() async {
    try {
      final response = await http.get(Uri.parse(
          'http://zct.us.kg:5000/api/download_history?userid=WET8644G3S463&user_role=teacher'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('加載歷史資料失敗，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('加載歷史資料過程中發生錯誤: $e');
    }
  }

  void _showDetailsDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${item['title']} 詳情'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('學年: ${item['academic_year']}'),
              Text('課程名稱: ${item['course_name']}'),
              Text('請假原因: ${item['leave_reason']}'),
              Text('描述: ${item['description']}'),
              Text('提交日期: ${item['submission_date']}'),
              Text('狀態: ${item['review_status']}'),
              Text('返回原因: ${item['return_reason']}'),
              Text('返回者: ${item['returned_by']}'),
              Text('評論者: ${item['reviewer']}'),
              Text('用戶角色: ${item['user_role']}'),
              Text('教師評論: ${item['teacher_comments']}'),
              Text('助教評論: ${item['ta_comments']}'),
              Text('課程資訊: ${item['course_info']}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('關閉'),
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
