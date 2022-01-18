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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataGrid(
          columns: [
            GridColumn(
                const Expanded(child: Center(child: Text("Text (read Only)"))),
                DataType.text,
                readOnly: true),
            GridColumn(
              const Expanded(
                  child: Center(child: Text("Checkbox (read only)"))),
              DataType.checkbox,
              alignment: Alignment.centerRight,
              readOnly: true,
            ),
            GridColumn(
              const Expanded(child: Center(child: Text("Text (editable)"))),
              DataType.text,
              validator: (col, row, value) {
                if (value != "Valid value") return "Wrong";
                return null;
              },
            ),
            GridColumn(
              const Expanded(child: Center(child: Text("Checkbox (editable)"))),
              DataType.checkbox,
            ),
            GridColumn(
              const Expanded(child: Center(child: Text("Widget"))),
              DataType.widget,
              readOnly: true,
            )
          ],
          rows: data,
        ),
      ),
    );
  }
}
