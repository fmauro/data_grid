library data_grid;

import 'package:flutter/material.dart';

class DataGrid extends StatelessWidget {
  const DataGrid(
      {Key? key,
      required this.columns,
      required this.rows,
      this.onValueChanged})
      : super(key: key);

  final List<GridColumn> columns;
  final List<GridRow> rows;

  final Function(
    int col,
    int row,
    dynamic value,
  )? onValueChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cellWidth = constraints.maxWidth / columns.length;
      return DataTable(
        horizontalMargin: 0,
        checkboxHorizontalMargin: 0,
        columnSpacing: 0,
        columns: columns.map((e) => DataColumn(label: e.label)).toList(),
        rows: [
          for (int r = 0; r < rows.length; r++)
            DataRow(cells: [
              for (int c = 0; c < columns.length; c++)
                _buildCell(c, r, cellWidth)
            ]),
        ],
      );
    });
  }

  DataCell _buildCell(int col, int row, double? cellWidth) {
    final cellValue = rows[row].cells[col];

    Widget child;
    switch (columns[col].type) {
      case DataType.text:
        child = Text(cellValue);
        break;
      case DataType.textFormField:
        child = TextFormField(
            readOnly: onValueChanged == null,
            initialValue: cellValue,
            onChanged: (value) {
              if (onValueChanged != null) {
                onValueChanged!(col, row, value);
              }
            });
        break;
      case DataType.checkbox:
        child = Checkbox(
            value: cellValue,
            onChanged: (value) {
              if (onValueChanged != null) {
                onValueChanged!(col, row, value);
              }
            });
        break;
      case DataType.widget:
        child = cellValue;
        break;
    }

    if (columns[col].validator != null) {
      final val = columns[col].validator!(col, row, cellValue);
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
}

class GridRow {
  final List<dynamic> cells;

  GridRow(this.cells);
}

class GridColumn {
  final Widget label;
  final DataType type;
  final String? Function(int col, int row, dynamic value)? validator;

  GridColumn(this.label, this.type, {this.validator});
}

enum DataType { text, textFormField, checkbox, widget }
