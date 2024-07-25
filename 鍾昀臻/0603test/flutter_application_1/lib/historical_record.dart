import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, bool> filterOptions = {
    '學年度': true,
    '節次': false,
    '日期': false,
    '課程名稱': false,
    '請假原因': false,
    '請假單': false,
    '選課單': false,
  };
  int currentPage = 1;
  final int totalPages = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查詢歷史紀錄'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildFilterOptions(),
            const SizedBox(height: 10),
            Expanded(child: _buildHistoryList()),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: '輸入對應資訊',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: filterOptions.keys.map((option) {
            return _buildFilterOption(option, filterOptions[option]!);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String text, bool value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: Colors.blue,
            onChanged: (newValue) {
              setState(() {
                filterOptions[text] = newValue!;
              });
            },
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: 10, // 假設有10個項目，根據需要更改
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage('https://via.placeholder.com/150'), // 用示例圖片網址
            ),
            title: Text('112學年度選課單'),
            subtitle: Text('Title\nDescription'),
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
        ),
        Text('$currentPage of $totalPages'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.blue,
      //accentColor: Colors.blueAccent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: HistoryPage(),
  ));
}
