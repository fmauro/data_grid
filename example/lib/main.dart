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

  int _activeRow = 0;
  int _activeCol = 0;
  dynamic _lastValue;

  late DataGridController controller;

  @override
  void initState() {
    super.initState();
    controller = DataGridController(
      columns: [
        GridColumn(
            const Expanded(child: Center(child: Text("Text (read Only)"))),
            ColumnType.text,
            readOnly: true),
        GridColumn(
          const Expanded(child: Center(child: Text("Checkbox (read only)"))),
          ColumnType.checkbox,
          alignment: Alignment.centerRight,
          readOnly: true,
        ),
        GridColumn(
          const Expanded(child: Center(child: Text("Text (editable)"))),
          ColumnType.text,
          validator: (col, row, value) {
            if (value != "Valid value") return "Wrong";
            return null;
          },
        ),
        GridColumn(
          const Expanded(child: Center(child: Text("Checkbox (editable)"))),
          ColumnType.checkbox,
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
        child: Column(
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.table_rows),
                ),
                Text("Focused row: $_activeRow"),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.table_view),
                ),
                Text("Focused column: $_activeCol"),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.query_builder),
                ),
                Text("Last value: $_lastValue"),
                IconButton(
                    onPressed: () => controller.setCellValue(0, 3, false),
                    icon: const Icon(Icons.text_snippet))
              ],
            ),
            DataGrid(
              minWidth: 1000,
              controller: controller,
              onFocusedRowChanged: (row) => setState(() => _activeRow = row),
              onFocusedColumnChanged: (col) => setState(() => _activeCol = col),
              onValueChanged: (col, row, value) =>
                  setState(() => _lastValue = value),
            ),
          ],
        ),
      ),
    );
  }
}
