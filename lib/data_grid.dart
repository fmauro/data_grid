library data_grid;

import 'package:flutter/material.dart';

class DataGrid extends StatefulWidget {
  const DataGrid(
      {Key? key,
      required this.columns,
      required this.rows,
      this.onValueChanged})
      : super(key: key);

  final List<GridColumn> columns;
  final List<dynamic> rows;

  final Function(int col, int row, dynamic value)? onValueChanged;

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int c = 0; c < widget.columns.length; c++) {
      if (widget.columns[c].type != DataType.textFormField) continue;
      for (int r = 0; r < widget.rows.length; r++) {
        final controller = TextEditingController();
        _controllers[c * widget.rows.length + r] = controller;
        controller.text = widget.rows[r][c];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cellWidth = constraints.maxWidth / widget.columns.length;
      return DataTable(
        horizontalMargin: 0,
        checkboxHorizontalMargin: 0,
        columnSpacing: 0,
        columns: widget.columns.map((e) => DataColumn(label: e.label)).toList(),
        rows: [
          for (int r = 0; r < widget.rows.length; r++)
            DataRow(cells: [
              for (int c = 0; c < widget.columns.length; c++)
                _buildCell(c, r, cellWidth)
            ]),
        ],
      );
    });
  }

  DataCell _buildCell(int col, int row, double? cellWidth) {
    final cellValue = widget.rows[row][col];

    Widget child;
    switch (widget.columns[col].type) {
      case DataType.text:
        child = Text(cellValue);
        break;
      case DataType.textFormField:
        final tff = TextFormField(
            decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                    left: 15, bottom: 11, top: 11, right: 15),
                hintText: widget.columns[col].hintText),
            controller: _controllers[col * widget.rows.length + row],
            readOnly: widget.onValueChanged == null,
            autofocus: false,
            onChanged: (value) {
              if (widget.onValueChanged != null) {
                widget.onValueChanged!(col, row, value);
              }
            });

        child = tff;
        break;
      case DataType.checkbox:
        child = Checkbox(
            value: cellValue,
            onChanged: (value) {
              if (widget.onValueChanged != null) {
                widget.onValueChanged!(col, row, value);
              }
            });
        break;
      case DataType.widget:
        child = cellValue;
        break;
    }

    if (widget.columns[col].validator != null) {
      final val = widget.columns[col].validator!(col, row, cellValue);
      if (val != null) {
        return DataCell(Container(
          width: cellWidth,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.red.withAlpha(50)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: child,
          ),
        ));
      }
    }

    return DataCell(SizedBox(
      width: cellWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: child,
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();

    for (var controller in _controllers.values) {
      controller.dispose();
    }
  }
}

class GridColumn {
  final Widget label;
  final DataType type;
  final String? Function(int col, int row, dynamic value)? validator;
  final String? hintText;

  GridColumn(this.label, this.type, {this.validator, this.hintText});
}

enum DataType { text, textFormField, checkbox, widget }
