import 'package:flutter/material.dart';
import 's.dart' as student;
import 't.dart' as teacher;
import 'z.dart' as assistant;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '測試APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter',
                style: Theme.of(context).textTheme.headlineMedium),
            ElevatedButton(
              onPressed: () {
                _navigateToPage(context, const student.StudentPage());
              },
              child: const Text('Go to 學生Page'),
            ),
            ElevatedButton(
              onPressed: () {
                _navigateToPage(context, const teacher.TeacherPage());
              },
              child: const Text('Go to 教師Page'),
            ),
            ElevatedButton(
              onPressed: () {
                _navigateToPage(context, const assistant.AssistantPage());
              },
              child: const Text('Go to 助教Page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
