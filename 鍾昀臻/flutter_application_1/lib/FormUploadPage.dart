import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FormUploadPage extends StatelessWidget {
  const FormUploadPage({Key? key}) : super(key: key);

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
                label: Text('表單名稱',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('所屬單位',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text('下載', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text('檢視', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Icon(Icons.info_outline, color: Colors.blue)),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('選課單')),
              DataCell(Text('科系')),
              DataCell(Text('下載')),
              DataCell(Text('檢視')),
              DataCell(Icon(Icons.keyboard_arrow_right, color: Colors.blue)),
            ]),
            DataRow(cells: [
              DataCell(Text('請假單')),
              DataCell(Text('學務處')),
              DataCell(Text('下載')),
              DataCell(Text('檢視')),
              DataCell(Icon(Icons.keyboard_arrow_right, color: Colors.blue)),
            ]),
            // 更多行數據...
          ],
        ),
      ),
    );
  }
}
