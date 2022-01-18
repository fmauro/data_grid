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
    ["test", "ttasdte", true, const Icon(Icons.ac_unit_outlined)],
    ["test", "ttteasdf", true, const Icon(Icons.ac_unit_outlined)],
    ["teasst", "ttte", true, const Icon(Icons.face)],
    ["teasdst", "ttasdfte", true, const Icon(Icons.file_download_done)],
    ["tedst", "tttdedf", false, const Icon(Icons.e_mobiledata_outlined)],
    ["tfasest", "ttte", true, const Icon(Icons.ac_unit_outlined)],
    ["teasdst", "tasdftte", true, const Icon(Icons.qr_code_2_outlined)],
    ["test", "tttea", false, const Icon(Icons.ac_unit_outlined)],
    ["tesddt", "ttasdfte", true, const Icon(Icons.tab_rounded)],
    ["teasdfstasdf", "ttadsfte", true, const Icon(Icons.ac_unit_outlined)],
    ["teasdfst", "ttteasdf", true, const Icon(Icons.ac_unit_outlined)],
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
          onValueChanged: (col, row, value) => setState(() {
            data[row][col] = value;
          }),
          columns: [
            GridColumn(const Text("First Column"), DataType.text),
            GridColumn(
              const Text("Second Column (Edit)"),
              DataType.textFormField,
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
            )
          ],
          rows: data,
        ),
      ),
    );
  }
}
