import 'package:flutter/material.dart';
import 'package:connect_to_sql_server_directly/connect_to_sql_server_directly.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<TestModel> studentsInfoList = [];
  List<TableRow> tableRowsList = [];
  bool isLoading = false;
  final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    getStudentsTableData();
  });
}

Future<void> getStudentsTableData() async {
  setState(() {
    isLoading = true;
  });
  bool isConnected = await _connectToSqlServerDirectlyPlugin.initializeConnection(
    '34.80.115.0',
    '0',
    '.',
    '.',
    instance: 'node',
  );
  if (isConnected) {
    try {
      var result = await _connectToSqlServerDirectlyPlugin.getRowsOfQueryResult("select * from ImageUploads");
      if (result.runtimeType == String) {
        onError(result);
      } else {
        List<Map<String, dynamic>> tempResult = result.cast<Map<String, dynamic>>();
        studentsInfoList = tempResult.map((element) => TestModel.fromMap(element)).toList();
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      onError(e.toString());
    }
  } else {
    onError('Unable to connect to database');
  }
}


void onError(String error) {
  // Implement error handling logic here
  // ignore: avoid_print
  print(error);  // Example: log to console or display a message
  setState(() {
    isLoading = false;
  });
}


  void createTableRows() {
    tableRowsList.clear();
    tableRowsList.add(
      const TableRow(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Id',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            'Name',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Weight',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
    for (var element in studentsInfoList) {
      tableRowsList.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                element.id.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              element.name.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            Text(
              (element.weight == null) ? '---' : element.weight.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> addRowDataToTable() async {
  bool result = false;
  try {
    final isConnected = await _connectToSqlServerDirectlyPlugin.initializeConnection(
      //Your serverIp
      '10.192.168.2',
      //Your databaseName
      'test_db',
      //Your username
      'Admin',
      //Your password
      'Admin',
      //Your instance
      instance: 'node',
    );

    if (isConnected) {
      final queryResult = await _connectToSqlServerDirectlyPlugin.getStatusOfQueryResult(
        (_weightController.text.isNotEmpty)
            ? "Insert Into dbo.testTable(Name, Weight) Values('${_nameController.text}', ${double.parse(_weightController.text)})"
            : "Insert Into dbo.testTable(Name, Weight) Values('${_nameController.text}', NULL)",
      );

      result = queryResult as bool;
    } else {
      onError('Failed to Register!');
    }
  } catch (error) {
    onError(error.toString());
  }

  if (result) {
    getStudentsTableData();
  }

  return;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Connect To Sql Server Directly'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          _nameController.clear();
          _weightController.clear();
          final formKey = GlobalKey<FormState>();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.all(16.0),
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                        key: formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text(
                                "Name",
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: TextFormField(
                                    validator: (String? value) {
                                      if (value != null && value.trim() == "") {
                                        return "Name can't be empty!";
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.done,
                                    controller: _nameController,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              "Weight",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(
                                        0, 0), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  controller: _weightController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^[0-9]+(.)?([0-9]+)?'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                addRowDataToTable();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                textDirection: TextDirection.rtl,
                                children: [
                                  Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                textDirection: TextDirection.rtl,
                                children: [
                                  Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Students  Sample Table",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              (!isLoading && studentsInfoList.isNotEmpty)
                  ? Table(
                      border: TableBorder.all(
                        color: Colors.black,
                        width: 1.0,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(0.3),
                        1: FlexColumnWidth(0.4),
                        2: FlexColumnWidth(0.3)
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: tableRowsList,
                    )
                  : (isLoading)
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('This Table is Empty!'),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestModel {
  final int id;
  final String name;
  final double? weight;

  TestModel({
    required this.id,
    required this.name,
    this.weight,
  });

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['Id'],
      name: map['Image'],
      weight: map['UploadDate'],
    );
  }
}
