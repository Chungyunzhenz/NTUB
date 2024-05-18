import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
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
          rows: [
            createDataRow(
                context, '2024-04-21', '14:30', '校園第一階段選課', '詳細信息關於校園第一階段選課'),
            createDataRow(
                context, '2024-05-21', '14:30', '校園第一週請假階段', '詳細信息關於校園第一週請假階段'),
          ],
        ),
      ),
    );
  }

  DataRow createDataRow(BuildContext context, String date, String time,
      String content, String detail) {
    return DataRow(cells: [
      DataCell(Text(date)),
      DataCell(Text(time)),
      DataCell(Text(content)),
      DataCell(Text('點擊進入查看詳情'), onTap: () {
        showDetail(context, detail);
      }),
      DataCell(Icon(Icons.keyboard_arrow_right, color: Colors.blue), onTap: () {
        showDetail(context, detail);
      }),
    ]);
  }

  void showDetail(BuildContext context, String detail) {
    // 顯示對話框以展示詳細信息
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('詳細資訊'),
          content: Text(detail),
          actions: <Widget>[
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
