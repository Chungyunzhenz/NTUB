import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// ignore: unused_import
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class FormDownloadPage extends StatefulWidget {
  const FormDownloadPage({Key? key}) : super(key: key);

  @override
  _FormDownloadPageState createState() => _FormDownloadPageState();
}

class _FormDownloadPageState extends State<FormDownloadPage> {
  String? _selectedDepartment;
  final List<Map<String, dynamic>> _forms = [
    {
      'name': '選課單',
      'department': '科系',
      'file': '選課單.pdf',
      'url': 'https://example.com/選課單.pdf', // 替換為實際的文件URL
    },
    {
      'name': '請假單',
      'department': '學務處',
      'file': '請假單.pdf',
      'url':
          'https://stud.ntub.edu.tw/app/index.php?Action=downloadfile&file=WVhSMFlXTm9MekV2Y0hSaFh6WTVNVGMyWHpneU9Ea3dYelkyTVRNeUxtOWtkQT09&fname=LOGGROOKWWCGA1YXEDLKSW24143025RLYSFG04XSVXGDXW40A0YW01SWWWOOA0OKZTPOZXKK200454HCMOXSTSLO34B0WSGCNPYTXWA034MKB001USSSWXFCMKPOCDNLDGA054WSVW30HCLK1434YSLK4435QPROLKB4YSSWIG00CDUSNOPOQPYXDGFGVWYWVWXSRLYS20RO14XSJDNPPOA5NKROECFGIGPOFCEGWWDCFD10TS24KPWWKKTWWTYWQO34SSMKTXJD40PKKPNO1145',
    },
  ];

  List<Map<String, dynamic>> get _filteredForms {
    return _selectedDepartment == null
        ? _forms
        : _forms
            .where((form) => form['department'] == _selectedDepartment)
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文件管理'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildDepartmentDropdown(),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(
                      label: Text('表單名稱',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('下載',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('檢視',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _filteredForms
                    .map((form) => DataRow(cells: [
                          DataCell(Text(form['name'])),
                          DataCell(IconButton(
                            icon: Icon(Icons.file_download),
                            onPressed: () => _downloadFile(
                                context, form['file'], form['url']),
                          )),
                          DataCell(IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: () => _viewFile(context, form['file']),
                          )),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        labelText: '選擇處室',
      ),
      value: _selectedDepartment,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down_circle),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Theme.of(context).primaryColor),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDepartment = newValue;
        });
      },
      items: <String>['科系', '學務處']
          .map((String department) => DropdownMenuItem<String>(
                value: department,
                child: Text(department),
              ))
          .toList(),
    );
  }

  Future<void> _downloadFile(
      BuildContext context, String fileName, String fileUrl) async {
    try {
      // Request storage permissions
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }

      var dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      String savePath = "${dir.path}/$fileName";

      await dio.download(fileUrl, savePath);

      _showDownloadSuccessDialog(context, savePath);
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _showDownloadSuccessDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('下載成功'),
        content: Text('文件已下載至: $filePath'),
        actions: <Widget>[
          TextButton(
            child: Text('關閉'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('下載失敗'),
        content: Text('錯誤: $errorMessage'),
        actions: <Widget>[
          TextButton(
            child: Text('關閉'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _viewFile(BuildContext context, String fileName) {
    // 模拟文件查看过程
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('查看文件'),
        content: Text('您正在查看: $fileName'),
        actions: <Widget>[
          TextButton(
            child: Text('關閉'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
