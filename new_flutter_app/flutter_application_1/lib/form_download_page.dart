import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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
  String? _selectedDepartment;
  final List<Map<String, dynamic>> _forms = [
    {
      'name': '選課單',
      'department': '科系',
      'file': '選課單.pdf',
      'url':
          'https://acad.ntub.edu.tw/app/index.php?Action=downloadfile&file=WVhSMFlXTm9MekkwTDNCMFlWODRNREV5TVY4MU5UUXpPVEF4WHprMU9ESXpMbVJ2WTNnPQ==&fname=WSGGTSB00010A1KKEDLKFCMOQOMO25GGYSB0UWYSQPGD0040QKA424540054FCEGPOPOHH00DG04ICHCFC30TSIGKL34B1NOVXVXA4CCYSA4RKSWWSKKUSSSRK40SS44',
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
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();
  }

  Future<void> _downloadFile(String fileName, String fileUrl) async {
    try {
      // Request storage permissions
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }

      var dio = Dio();
      String dir = '/storage/emulated/0/Download';
      String savePath = "$dir/$fileName";

      await dio.download(fileUrl, savePath);

      if (mounted) {
        _showDownloadSuccessDialog(context, savePath);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showDownloadSuccessDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('下載成功'),
        content: Text('文件已下載至: $filePath'),
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

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('下載失敗'),
        content: Text('錯誤: $errorMessage'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下載表單'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: const Text('選擇科系'),
            value: _selectedDepartment,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDepartment = newValue;
              });
            },
            items: <String>['科系', '學務處']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredForms.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredForms[index]['name']),
                  onTap: () {
                    _downloadFile(
                      _filteredForms[index]['file'],
                      _filteredForms[index]['url'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
