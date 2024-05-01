// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  // ignore: use_super_parameters
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('公告'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          columns: const [
            DataColumn(
                label:
                    Text('日期', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text('時間', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('資訊內容',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('詳細內容',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Icon(Icons.info_outline, color: Colors.blue)),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('2024-04-21')),
              DataCell(Text('14:30')),
              DataCell(Text('校園第一階段選課')),
              DataCell(Text('點擊進入查看詳情')),
              DataCell(Icon(Icons.keyboard_arrow_right, color: Colors.blue)),
            ]),
            DataRow(cells: [
              DataCell(Text('2024-05-21')),
              DataCell(Text('14:30')),
              DataCell(Text('校園第一週請假階段')),
              DataCell(Text('點擊進入查看詳情')),
              DataCell(Icon(Icons.keyboard_arrow_right, color: Colors.blue)),
            ]),
            // 更多行數據...
          ],
        ),
      ),
    );
  }
}
