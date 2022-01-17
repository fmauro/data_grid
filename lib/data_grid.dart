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
                _buildCell(r, c, cellWidth)
            ]),
        ],
      );
    });
  }

  DataCell _buildCell(int rowIndex, int columnIndex, double? cellWidth) {
    final row = rows[rowIndex];

    switch (columns[columnIndex].type) {
      case DataType.text:
        return DataCell(SizedBox(
          child: Text(row.cells[columnIndex]),
          width: cellWidth,
        ));
      case DataType.textFormField:
        return DataCell(SizedBox(
          child: TextFormField(
            readOnly: onValueChanged == null,
            initialValue: row.cells[columnIndex],
            onChanged: (value) {
              if (onValueChanged != null) {
                onValueChanged!(columnIndex, rowIndex, value);
              }
            },
            autovalidateMode: AutovalidateMode.always,
          ),
          width: cellWidth,
        ));
      case DataType.checkbox:
        return DataCell(SizedBox(
          child: Checkbox(
              value: row.cells[columnIndex],
              onChanged: (value) {
                if (onValueChanged != null) {
                  onValueChanged!(columnIndex, rowIndex, value);
                }
              }),
          width: cellWidth,
        ));
      case DataType.widget:
        return DataCell(
            SizedBox(child: row.cells[columnIndex], width: cellWidth));
    }
  }
}

class GridRow {
  final List<dynamic> cells;

  GridRow(this.cells);
}

class GridColumn {
  final Widget label;
  final DataType type;

  GridColumn(this.label, this.type);
}

enum DataType { text, textFormField, checkbox, widget }
