import 'package:data_grid/data_grid.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Data Grid example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<dynamic>> data = [
    ["Sit amet", true, "Lorem ipsum", true, const Icon(Icons.ac_unit)],
    ["Grum drum", true, "Valid value", true, const Icon(Icons.face)],
    ["Baja blast", false, "Invalid value", true, const Icon(Icons.adjust)],
    ["Train station", true, "Test text", true, null],
    ["Workplace", false, "More tests", false, null],
  ];

  late DataGridController controller;

  @override
  void initState() {
    super.initState();
    controller = DataGridController(
      columns: [
        GridColumn(
          const Expanded(child: Center(child: Text("Text (read Only)"))),
          ColumnType.text,
          readOnly: true,
          onSort: (one, two) => one.compareTo(two),
        ),
        GridColumn(
          const Expanded(child: Center(child: Text("Checkbox (editable)"))),
          ColumnType.checkbox,
          alignment: Alignment.centerRight,
        ),
        GridColumn(
          const Expanded(child: Center(child: Text("Text (editable)"))),
          ColumnType.text,
          validator: (col, row, value) {
            if (value != "Valid value") return "Wrong";
            return null;
          },
          flex: 4,
          textAlign: TextAlign.left,
          onSort: (one, two) => one.compareTo(two),
        ),
        GridColumn(
          const Expanded(child: Center(child: Text("Checkbox (read only)"))),
          ColumnType.checkbox,
          readOnly: true,
        ),
        GridColumn(
          const Expanded(child: Center(child: Text("Widget"))),
          ColumnType.widget,
          readOnly: true,
        )
      ],
      rows: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              IconButton(
                  onPressed: () => controller
                      .addRow(["Train station", true, "Test text", true, null]),
                  icon: Icon(Icons.add)),
              DataGrid(
                minWidth: 1000,
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
