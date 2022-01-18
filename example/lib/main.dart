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
    ["test", true, "ttasdte", true, const Icon(Icons.ac_unit_outlined)],
    ["test", true, "ttteasdf", true, const Icon(Icons.ac_unit_outlined)],
    ["teasst", true, "ttte", true, const Icon(Icons.face)],
    ["teasdst", true, "ttasdfte", true, const Icon(Icons.file_download_done)],
    ["tedst", true, "tttdedf", false, const Icon(Icons.e_mobiledata_outlined)],
    ["tfasest", true, "ttte", true, const Icon(Icons.ac_unit_outlined)],
    ["teasdst", true, "tasdftte", true, const Icon(Icons.qr_code_2_outlined)],
    ["test", true, "tttea", false, const Icon(Icons.ac_unit_outlined)],
    ["tesddt", true, "ttasdfte", true, const Icon(Icons.tab_rounded)],
    ["teasdfssdf", true, "ttadsfte", true, const Icon(Icons.ac_unit_outlined)],
    ["teasdfst", true, "ttteasdf", true, const Icon(Icons.ac_unit_outlined)],
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
          // onValueChanged: (col, row, value) => setState(() {
          //   data[row][col] = value;
          // }),
          columns: [
            GridColumn(const Text("First Column"), DataType.text,
                readOnly: true),
            GridColumn(
              const Text("Intermediate Column"),
              DataType.checkbox,
              validator: (col, row, value) {
                if (value != true) return "wrong value";
                return null;
              },
              readOnly: true,
            ),
            GridColumn(
              const Text("Second Column (Edit)"),
              DataType.text,
              validator: (col, row, value) {
                if (value != "Tessst") return "wrong value";
                return null;
              },
            ),
            GridColumn(
              const Text("Third Column"),
              DataType.checkbox,
              validator: (col, row, value) {
                if (value != true) return "wrong value";
                return null;
              },
            ),
            GridColumn(
              const Text("Widget Column"),
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
