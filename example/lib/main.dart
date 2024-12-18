import 'package:table_advanced/table_advanced.dart';
import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<String>? items = [];

  Future<void> initialList() async {
    await Future.delayed(const Duration(seconds: 4));
    List<String> newItems = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    setState(() {
      items?.addAll(newItems);
    });
  }

  Future<List<String>> page2() async {
    await Future.delayed(const Duration(seconds: 4));
    List<String> newItems = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "15"
    ];
    return newItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: TableAdvanced<String>(
        columnHeaders: [
          TableAdvancedColumnHeader(
            child: const Text("Header 1"),
          ),
          TableAdvancedColumnHeader(
            child: const Text("Header 2"),
          ),
        ],
        rowBuilder: (item) {
          return TableAdvancedRow(
            data: DataRow(cells: [
              DataCell(Text(item)),
              DataCell(Container(
                  color: Colors.red, child: const Text("Test value"))),
            ]),
          );
        },
        controller: TableAdvancedController(
          items: items,
          mode: TableMode.paginationPage,
          onCheckItems: (items) {},
          onChangePage: (page, pageSize) => page2(),
        ),
      ),
    );
  }
}
