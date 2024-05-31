import 'package:flutter/material.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key}); // 使用 super 参数

  @override
  AnnouncementPageState createState() => AnnouncementPageState();
}

class AnnouncementPageState extends State<AnnouncementPage> {
  List<Announcement> announcements = [
    Announcement(
        date: '2024-04-21',
        time: '14:30',
        location: '校園',
        content: '第一階段選課',
        detail: '詳細信息關於校園第一階段選課'),
    Announcement(
        date: '2024-05-21',
        time: '09:00',
        location: '校園',
        content: '第一週請假階段',
        detail: '詳細信息關於校園第一週請假階段'),
    Announcement(
        date: '2024-05-22',
        time: '10:00',
        location: '教室',
        content: '期中考試',
        detail: '詳細信息關於期中考試'),
  ];

  bool isAscending = true;
  String selectedLocation = '全部';

  List<String> locations = ['全部', '校園', '教室'];

  void sortData() {
    setState(() {
      announcements.sort((a, b) {
        int dateComparison = a.date.compareTo(b.date);
        if (dateComparison == 0) {
          return a.time.compareTo(b.time);
        }
        return dateComparison;
      });

      if (!isAscending) {
        announcements = announcements.reversed.toList();
      }
    });
  }

  void toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      sortData();
    });
  }

  List<Announcement> getFilteredAnnouncements() {
    if (selectedLocation == '全部') {
      return announcements;
    }
    return announcements
        .where((announcement) => announcement.location == selectedLocation)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    sortData();
  }

  @override
  Widget build(BuildContext context) {
    List<Announcement> filteredAnnouncements = getFilteredAnnouncements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('公告'), // 使用 const
        actions: [
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: toggleSortOrder,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLocation = newValue!;
                });
              },
              items: locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
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
                label:
                    Text('處所', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('資訊內容',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('詳細內容',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Icon(Icons.info_outline, color: Colors.blue)),
          ],
          rows: filteredAnnouncements.map((announcement) {
            return createDataRow(
              context,
              announcement.date,
              announcement.time,
              announcement.location,
              announcement.content,
              announcement.detail,
            );
          }).toList(),
        ),
      ),
    );
  }

  DataRow createDataRow(BuildContext context, String date, String time,
      String location, String content, String detail) {
    return DataRow(cells: [
      DataCell(Text(date)),
      DataCell(Text(time)),
      DataCell(Text(location)),
      DataCell(Text(content)),
      DataCell(const Text('點擊查看詳情'), onTap: () {
        showDetail(context, detail);
      }),
      DataCell(const Icon(Icons.keyboard_arrow_right, color: Colors.blue),
          onTap: () {
        showDetail(context, detail);
      }),
    ]);
  }

  void showDetail(BuildContext context, String detail) {
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

class Announcement {
  String date;
  String time;
  String location;
  String content;
  String detail;

  Announcement({
    required this.date,
    required this.time,
    required this.location,
    required this.content,
    required this.detail,
  });
}
